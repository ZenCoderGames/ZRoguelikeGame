// Fill out your copyright notice in the Description page of Project Settings.


#include "TetrominoSpawner.h"

#include "TetrominoPiece.h"
#include "WorldUtility.h"
#include "Config/Tetris3DGameConfig.h"
#include "GameFramework/GameplayMessageSubsystem.h"
#include "Tetris3D/Types/GameplayMessages.h"


// Sets default values
ATetrominoSpawner::ATetrominoSpawner()
{
	// Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;
}

void ATetrominoSpawner::Initialize(TObjectPtr<UTetris3DGameConfig> InGameConfig, TObjectPtr<UWorldUtility> InWorldUtility)
{
	// Todo: Calculate the total ratio only once
	GameConfig = InGameConfig;
	WorldUtility = InWorldUtility;

	if (GetClass()->HasAnyClassFlags(CLASS_CompiledFromBlueprint) || !GetClass()->HasAnyClassFlags(CLASS_Native))
	{
		BP_Initialize();
	}
}

bool ATetrominoSpawner::MovePiece()
{
	if(CurrentPiece == nullptr || CurrentPiece->Stopped)
		return true;

	bool TryFall = CurrentPiece->Translate(FIntVector(0, 0, -1));
	if(TryFall == false)
	{
		CurrentPiece->Stopped = true;
		// Todo: Cache
		// UGameplayMessageSubsystem& MessageSubsystem = UGameplayMessageSubsystem::Get(GetWorld());
		// MessageSubsystem.BroadcastMessage(FGameplayTag::RequestGameplayTag("Events.Piece.Stopped"), FGameplayMessagePiece{CurrentPiece});
	}
	return TryFall;
}
void ATetrominoSpawner::Replace()
{
	ATetrominoPiece* Piece = CurrentPiece;
	CurrentPiece = nullptr;
	auto Locations = WorldUtility->GetNewLocations(Piece->GridPos, Piece->TetrominoConfig->Blocks, Piece->Rotation);
	for (auto Location : Locations)
	{
		if(Location.Z >= GameConfig->Dimensions.Z)
		{
			UGameplayMessageSubsystem& MessageSubsystem = UGameplayMessageSubsystem::Get(GetWorld());
			MessageSubsystem.BroadcastMessage(FGameplayTag::RequestGameplayTag("Events.Game.Over"), FGameplayMessageStatus{"Game Over"});
			return;
		}
		if (const auto BaseBlock = GetWorld()->SpawnActor<ABlockBase>(BaseBlockClass, SpawnLocation->GetActorLocation(), SpawnLocation->GetActorRotation()))
		{
			BaseBlock->Init(Location, Piece->TetrominoConfig->Color);
			WorldUtility->SetFlag(Location);
		}
	}
	Piece->Destroy();
}

float ATetrominoSpawner::GetTotalRatio() const
{
	float TotalRatio = 0.f;
	for (auto& Pair : GameConfig->TetrominoRatios)
	{
		TotalRatio += Pair.Value;
	}
	return TotalRatio;
}

void ATetrominoSpawner::SpawnTetrominoPiece()
{
	if (!TetrominoClass)
	{
		UE_LOG(LogTemp, Error, TEXT("No Tetromino class set for spawner."));
		return;
	}

	float TotalRatio = GetTotalRatio();
	if (TotalRatio <= 0.f)
	{
		UE_LOG(LogTemp, Error, TEXT("Total spawn ratio is 0. Cannot spawn tetromino."));
		return;
	}

	if(NextPiece == nullptr) CreateNextTetromino(TotalRatio);
	CurrentPiece = NextPiece;
	CurrentPiece->SetWorldPosition();
	CreateNextTetromino(TotalRatio);
	UGameplayMessageSubsystem& MessageSubsystem = UGameplayMessageSubsystem::Get(GetWorld());
	MessageSubsystem.BroadcastMessage(FGameplayTag::RequestGameplayTag("Events.Piece.Spawned"), FGameplayMessagePiece{CurrentPiece});
}

void ATetrominoSpawner::CreateNextTetromino(float TotalRatio)
{
	float SpawnRoll = FMath::RandRange(0.f, TotalRatio);
	float RatioAccum = 0.f;

	for (auto& Pair : GameConfig->TetrominoRatios)
	{
		RatioAccum += Pair.Value;
		if (SpawnRoll <= RatioAccum)
		{
			NextPiece = GetWorld()->SpawnActor<ATetrominoPiece>(TetrominoClass, SpawnLocation->GetActorLocation(), SpawnLocation->GetActorRotation());
			if (NextPiece)
			{
				NextPiece->Init(Pair.Key, GridLocation);
			}
			break;
		}
	}
}

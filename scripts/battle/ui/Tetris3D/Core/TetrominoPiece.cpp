// Fill out your copyright notice in the Description page of Project Settings.


#include "TetrominoPiece.h"
#include "Config/TetrominoConfig.h"
#include "Tetris3D/TetrisGameplayStatics.h"
#include "Tetris3D/Types/TetrominoConf.h"

// Sets default values
ATetrominoPiece::ATetrominoPiece()
{
	// Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;
	Stopped = false;
}

void ATetrominoPiece::GenerateBlocks()
{
	if (TetrominoConfig)
	{
		AddBlockComponent(FIntVector());
		for (const FIntVector& BlockLocation : TetrominoConfig->Blocks)
		{
			AddBlockComponent(BlockLocation);
		}
	}
}

void ATetrominoPiece::SetWorldPosition() const
{
	if(const auto WorldUtility = UTetrisGameplayStatics::GetWorldUtility(this))
	{
		const auto WorldPos = WorldUtility->GetWorldPositionFromGridPosition(GridPos);
		RootComponent->SetWorldLocation(WorldPos);
	}
}

void ATetrominoPiece::Init(UTetrominoConfig* Key, FIntVector IntVector)
{
	TetrominoConfig = Key;
	this->GridPos = IntVector;
	// SetWorldPosition();
	GenerateBlocks();
}

bool ATetrominoPiece::Translate(FIntVector Location)
{
	if(const auto WorldUtility = UTetrisGameplayStatics::GetWorldUtility(this))
	{
		if(WorldUtility->IsLocationValid(GridPos + Location, TetrominoConfig->Blocks, Rotation) == false)
		{
			return false;
		}
		GridPos += Location;
		const auto WorldPos = WorldUtility->GetWorldPositionFromGridPosition(GridPos);
		RootComponent->SetWorldLocation(WorldPos);
	}
	return true;
}

void ATetrominoPiece::Rotate(bool X, bool Y)
{
	Rotation += FIntVector(90 * X, 90 * Y, 0);
}

void ATetrominoPiece::AddBlockComponent(const FIntVector& Location)
{
	static int index = 0;
	FText Prefix = FText::FromString("TetrisBlock");
	FText BlockName = FText::Format(FText::FromString("{0}_{1}"), Prefix, index++);
	if (UBlockComponent* NewBlockComponent = NewObject<UBlockComponent>(this, BlockComponentClass, FName(*BlockName.ToString())))
	{
		NewBlockComponent->RegisterComponent();
		// NewBlockComponent->SetupAttachment(RootComponent);
		NewBlockComponent->AttachToComponent(GetRootComponent(), FAttachmentTransformRules::KeepRelativeTransform);
		NewBlockComponent->SetGridOffset(Location);
		NewBlockComponent->SetRelativeLocation(FVector(Location) * 50);
		NewBlockComponent->SetGlowColor(TetrominoConfig->Color);

		BlockComponents.Add(NewBlockComponent);
	}
}

// Called when the game starts or when spawned
void ATetrominoPiece::BeginPlay()
{
	Super::BeginPlay();
}

// Called every frame
void ATetrominoPiece::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);
}

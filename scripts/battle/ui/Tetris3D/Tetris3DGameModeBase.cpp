// Copyright Epic Games, Inc. All Rights Reserved.


#include "Tetris3DGameModeBase.h"

#include "AbilitySystemComponent.h"
#include "Core/GameRoomPawn.h"
#include "Core/TetrisGameHUD.h"
#include "Core/WorldUtility.h"
#include "GameFramework/GameplayMessageSubsystem.h"
#include "Kismet/GameplayStatics.h"

ATetris3DGameModeBase::ATetris3DGameModeBase()
{
	AbilitySystemComponent = CreateDefaultSubobject<UAbilitySystemComponent>(TEXT("AbilitySystemComp"));
}

UAbilitySystemComponent* ATetris3DGameModeBase::GetAbilitySystemComponent() const
{
	return AbilitySystemComponent;
}

void ATetris3DGameModeBase::PostInitializeComponents()
{
	Super::PostInitializeComponents();

	if(AbilitySystemComponent)
	{
		AActor* OwnerActor = this; // The one who logically owns this character
		AActor* AvatarActor = this; // Usually the pawn; If ASC moves in PlayerController, this should still be the Actor/Character
		AbilitySystemComponent->InitAbilityActorInfo(OwnerActor, AvatarActor);
		UE_LOG(LogTemp, Display, TEXT("Ability System Owner and Avatar Set! [Actor = %s]"), *GetNameSafe(this));
	}
	
	if(GetWorld()->IsGameWorld())
	{
		AttributeSetComponent = NewObject<UTetrisAttributeSet>(this, UTetrisAttributeSet::StaticClass());
		AbilitySystemComponent->AddAttributeSetSubobject(AttributeSetComponent.Get());
		UE_LOG(LogTemp, Display, TEXT("Added Attribute Set! [Actor = %s] [AttributeSet = SmartAttributeSetBase-yes]"), *GetNameSafe(this));
	}
}

void ATetris3DGameModeBase::BeginPlay()
{
	Super::BeginPlay();
	InitializeGame();
}

void ATetris3DGameModeBase::Tick(float DeltaSeconds)
{
	Super::Tick(DeltaSeconds);
	if(DeltaSeconds > TickFrequency) return;
	this->ElapsedTime += DeltaSeconds;
	if(ElapsedTime >= TickFrequency)
	{
		ElapsedTime -= TickFrequency;
		TetrisGameTick();
	}
}

void ATetris3DGameModeBase::InitializeGame()
{
	// Listeners
	UGameplayMessageSubsystem& MessageSubsystem = UGameplayMessageSubsystem::Get(GetWorld());
	// Todo: Request these tags from a data asset
	MessageSubsystem.RegisterListener(FGameplayTag::RequestGameplayTag("Events.Piece.Stopped"), this, &ATetris3DGameModeBase::OnTetrominoStopped);
	
	// WorldUtility
	WorldUtility = NewObject<UWorldUtility>();
	WorldUtility->Initialize(GameConfig->Dimensions, GameConfig->BlockSize, GridWorldOffset);
	WorldUtility->AddToRoot();
	
	// Spawner
	TArray<AActor*> FoundActors;
	UGameplayStatics::GetAllActorsOfClass(GetWorld(), ATetrominoSpawner::StaticClass(), FoundActors);
	if(FoundActors.Num() == 0)
	{
		// TODO: Check for Initialization
		return;
	}

	TetrominoSpawner = Cast<ATetrominoSpawner>(FoundActors[0]);
	TetrominoSpawner->Initialize(GameConfig, WorldUtility);

	// Pawn Setup
	APawn* MyPawn = UGameplayStatics::GetPlayerPawn(this, 0);
	if(AGameRoomPawn* GameRoom = Cast<AGameRoomPawn>(MyPawn))
	{
		GameRoom->InitRoom(GameConfig->Dimensions, AbilitySystemComponent);
	}

	// Game HUD
	APlayerController* PlayerController = UGameplayStatics::GetPlayerController(this, 0);
	if(ATetrisGameHUD* GameHUD = Cast<ATetrisGameHUD>(PlayerController->GetHUD()))
	{
		GameHUD->Initialize();
	}

	// Granting Abilities
	AbilitySystemComponent->GetGameplayAttributeValueChangeDelegate(UTetrisAttributeSet::GetFallSpeedAttribute()).AddUObject(this, &ATetris3DGameModeBase::OnFallSpeedChange);
	for (const auto& AbilityClass : GameConfig->Abilities)
	{
		AcquireAbility(AbilityClass);
	}
	const UGameplayEffect* GameplayEffect = GameConfig->DefaultAttributesEffect->GetDefaultObject<UGameplayEffect>();
	const FActiveGameplayEffectHandle GameplayEffectHandle = AbilitySystemComponent->ApplyGameplayEffectToSelf(GameplayEffect, 1, AbilitySystemComponent->MakeEffectContext());

	// Initialization code from blueprint
	if (GetClass()->HasAnyClassFlags(CLASS_CompiledFromBlueprint) || !GetClass()->HasAnyClassFlags(CLASS_Native))
	{
		BP_Initialize();
	}
}

void ATetris3DGameModeBase::OnFallSpeedChange(const FOnAttributeChangeData& FallSpeed)
{
	if(FallSpeed.NewValue == 0)
	{
		TickFrequency = 1;
		return;
	}
	TickFrequency = 1 / FallSpeed.NewValue;
}

void ATetris3DGameModeBase::TetrisGameTick()
{
	if(TetrominoSpawner->MovePiece() == false)
	{
		TetrominoSpawner->Replace();

		// Check the World Utility
		// Decide between GameOver/ClearRow/Spawn
		TetrominoSpawner->SpawnTetrominoPiece();
	}
}

void ATetris3DGameModeBase::OnTetrominoStopped(FGameplayTag GameplayTag, const FGameplayMessagePiece& MessageData)
{
	// if(MessageData.Piece->Stopped == false)
	// {
	// 	return;
	// }
	// TetrominoSpawner->Replace();
	// TetrominoSpawner->SpawnTetrominoPiece();
}

FGameplayAbilitySpecHandle ATetris3DGameModeBase::AcquireAbility(TSubclassOf<UGameplayAbility> InAbility)
{
	if(AbilitySystemComponent == nullptr || InAbility == nullptr) return FGameplayAbilitySpecHandle();
	if(HasAuthority() == false) return FGameplayAbilitySpecHandle();

	constexpr int Level = 1; 
	constexpr int InputID = 0; // Note: InputID(INDEX_NONE=-1 by default), and InSourceObject(Object that created the ability, nullptr by default)
	const FGameplayAbilitySpec AbilitySpec = FGameplayAbilitySpec(InAbility, Level, InputID);
	const FGameplayAbilitySpecHandle SpecHandle = AbilitySystemComponent->GiveAbility(AbilitySpec);

	return SpecHandle;
}

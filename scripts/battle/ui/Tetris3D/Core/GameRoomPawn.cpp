// Fill out your copyright notice in the Description page of Project Settings.


#include "GameRoomPawn.h"

#include "GameRoom.h"
#include "Camera/CameraComponent.h"
#include "GameFramework/GameplayMessageSubsystem.h"
#include "Tetris3D/Types/GameplayMessages.h"


// Sets default values
AGameRoomPawn::AGameRoomPawn()
{
	// Set this pawn to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;

	DefaultSceneRoot = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("DefaultSceneRoot"));
	RootComponent = DefaultSceneRoot;
	
	Ground = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Floor"));
	Ground->SetupAttachment(RootComponent);

	FollowCamera = CreateDefaultSubobject<UCameraComponent>(TEXT("FollowCamera"));
	FollowCamera->SetupAttachment(RootComponent);
	
	// Ground = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Floor"));
	// Ground->SetupAttachment(RootComponent);
	//
	// Ground = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Floor"));
	// Ground->SetupAttachment(RootComponent);
	//
	// Ground = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Floor"));
	// Ground->SetupAttachment(RootComponent);
	//
	// Ground = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Floor"));
	// Ground->SetupAttachment(RootComponent);
}

UAbilitySystemComponent* AGameRoomPawn::GetAbilitySystemComponent() const
{
	return AbilitySystemComponent;
}

// Called when the game starts or when spawned
void AGameRoomPawn::BeginPlay()
{
	Super::BeginPlay();
}

// Called every frame
void AGameRoomPawn::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);
}

// Called to bind functionality to input
void AGameRoomPawn::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);
}

void AGameRoomPawn::InitRoom(const FIntVector& InDimensions, TObjectPtr<UAbilitySystemComponent> InASC)
{
	AbilitySystemComponent = InASC;
	Dimensions = InDimensions;

	RootComponent->SetWorldLocation(FVector(0.f, 0.f, 0.f));
	RootComponent->SetWorldRotation(FQuat::Identity);

	FVector Translation(Dimensions.X * 50/2, Dimensions.Y*50/2, -50.0f);
	FRotator Rotation(FQuat::Identity);
	FVector Scale(Dimensions.X/2, Dimensions.Y/2, 1.0f);
	FTransform GroundTransform(Rotation, Translation, Scale);
	
	Ground->SetWorldTransform(GroundTransform);

	UGameplayMessageSubsystem& MessageSubsystem = UGameplayMessageSubsystem::Get(GetWorld());
	// Todo: Request these tags from a data asset
	MessageSubsystem.RegisterListener(FGameplayTag::RequestGameplayTag("Events.Piece.Spawned"), this, &AGameRoomPawn::OnNewPieceSpawn);
}

void AGameRoomPawn::OnNewPieceSpawn(FGameplayTag GameplayTag, const FGameplayMessagePiece& MessageData)
{
	ActivePiece = MessageData.Piece;
	GEngine->AddOnScreenDebugMessage(-1, 5.0f, FColor::Red, "New Piece Spawned");
}



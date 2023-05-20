// Fill out your copyright notice in the Description page of Project Settings.


#include "BlockBase.h"

#include "BlockComponent.h"
#include "Tetris3D/TetrisGameplayStatics.h"


// Sets default values
ABlockBase::ABlockBase()
{
	// Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;
	
}

// Called when the game starts or when spawned
void ABlockBase::BeginPlay()
{
	Super::BeginPlay();
	
}

// Called every frame
void ABlockBase::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);
}

void ABlockBase::Init(FIntVector Location, FLinearColor InColor)
{
	Position = Location;
	if (UBlockComponent* NewBlockComponent = NewObject<UBlockComponent>(this, BlockComponentClass, FName("MainBlock")))
	{
		NewBlockComponent->RegisterComponent();
		NewBlockComponent->AttachToComponent(GetRootComponent(), FAttachmentTransformRules::KeepRelativeTransform);
		// NewBlockComponent->SetRelativeLocation(FVector(Location) * 50);
		NewBlockComponent->SetGlowColor(InColor);
		if(const auto WorldUtility = UTetrisGameplayStatics::GetWorldUtility(this))
		{
			const auto WorldPos = WorldUtility->GetWorldPositionFromGridPosition(Position);
			RootComponent->SetWorldLocation(WorldPos);
		}
	}
}


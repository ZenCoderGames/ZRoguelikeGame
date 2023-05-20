// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "BlockComponent.h"
#include "Config/TetrominoConfig.h"
#include "GameFramework/Actor.h"
#include "BlockBase.generated.h"

UCLASS()
class TETRIS3D_API ABlockBase : public AActor
{
	GENERATED_BODY()

public:
	// Sets default values for this actor's properties
	ABlockBase();

protected:
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;

public:
	// Called every frame
	virtual void Tick(float DeltaTime) override;
	void Init(FIntVector Location, FLinearColor Color);

	FIntVector Position;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TSubclassOf<UBlockComponent> BlockComponentClass;
};

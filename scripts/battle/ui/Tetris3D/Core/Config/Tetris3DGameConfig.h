// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "TetrominoConfig.h"
#include "Engine/DataAsset.h"
#include "Abilities/GameplayAbility.h"
#include "Tetris3DGameConfig.generated.h"

/**
 * Game Configuration
 */
UCLASS()
class TETRIS3D_API UTetris3DGameConfig : public UDataAsset
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D|Config")
	FIntVector Dimensions; // Note - UIntVector is not supported by Blueprints

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D|Config")
	TMap<UTetrominoConfig*, float> TetrominoRatios;

	// UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Tetris3D|Config")
	// TMap<FTetrominoConf, float> PieceRatios; // Note: Handler to assign a row from a data table

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Tetris3D|Config")
	TArray<TSubclassOf<UGameplayAbility>> Abilities;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Tetris3D|Config")
	TSubclassOf<UGameplayEffect> DefaultAttributesEffect;
	
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D|Config")
	float BlockSize = 100;
};

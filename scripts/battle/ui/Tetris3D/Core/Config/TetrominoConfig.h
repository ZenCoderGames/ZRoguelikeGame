// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Engine/DataAsset.h"
#include "TetrominoConfig.generated.h"

/**
 * Configuration for a Tetromino Piece
 */
UCLASS()
class TETRIS3D_API UTetrominoConfig : public UDataAsset
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D|Config")
	TArray<FIntVector> Blocks;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D|Config")
	FLinearColor Color;
};

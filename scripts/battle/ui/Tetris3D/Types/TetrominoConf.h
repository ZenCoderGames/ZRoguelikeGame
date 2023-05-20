#pragma once

#include "CoreMinimal.h"
#include "Engine/DataTable.h"
#include "TetrominoConf.generated.h"

USTRUCT(BlueprintType, Blueprintable)
struct FTetrominoConf: public FTableRowBase // Note: Base class for creat
{
	GENERATED_USTRUCT_BODY()

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D|Config")
	TArray<FIntVector> Blocks;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D|Config")
	FLinearColor Color;
};
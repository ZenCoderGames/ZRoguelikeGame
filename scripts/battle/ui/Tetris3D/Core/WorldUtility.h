// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Tetris3D/Types/BitArray.h"
#include "UObject/Object.h"
#include "WorldUtility.generated.h"

class UTetris3DGameConfig;

USTRUCT(BlueprintType)
struct FPlaneData
{
	GENERATED_BODY()
public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D")
	TArray<bool> Occupied;
	int32 OccupiedCount;
	
	void InitData(const int32 Length, const int32 Width)
	{
		OccupiedCount = 0;
		Occupied.Init(false, Length * Width);
	}

	bool IsOccupied(int Index)
	{
		if(Index < 0 || Index >= Occupied.Num())
		{
			return false;
		}
		return Occupied[Index];
	}

	void SetOccupied(int Index)
	{
		if(Occupied[Index] == false)
		{
			Occupied[Index] = true;
			OccupiedCount++;
		}
	}

	
};

/**
 * WorldUtility
 */
UCLASS()
class TETRIS3D_API UWorldUtility : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	TObjectPtr<UTetris3DGameConfig> GameConfig;
	
	FVector GridWorldOffset;

	void Initialize(const FIntVector& Dimensions, const float InBlockSize, const FVector& GridWorldOffset);
	

	// World Utility Functions
	/** Converts a grid position to a world position */
	UFUNCTION(BlueprintPure, Category = "Tetris3D|Utilities")
	FVector GetWorldPositionFromGridPosition(const FIntVector& GridPosition) const;

	/** Converts a world position to a grid position */
	UFUNCTION(BlueprintPure, Category = "Tetris3D|Utilities")
	FIntVector GetGridPositionFromWorldPosition(const FVector& WorldPosition) const;

	UFUNCTION(BlueprintCallable)
	bool IsLocationValid(FIntVector BasePosition, TArray<FIntVector> Positions, FIntVector Rotation);

	UFUNCTION(BlueprintCallable)
	TArray<FIntVector> GetNewLocations(FIntVector BasePosition, TArray<FIntVector> Positions, FIntVector Rotation);

	// UFUNCTION(BlueprintCallable)
	// bool FillPosition(const FIntVector& BlockPosition);
	//
	// UFUNCTION(BlueprintCallable)
	// void ClearRow(const int32 Index);

	UFUNCTION(BlueprintCallable)
	bool IsInBounds(const FIntVector& BlockPosition);

	UFUNCTION(BlueprintCallable)
	bool IsOccupied(const FIntVector& BlockPosition);

	void SetFlag(FIntVector Location);

private:
	FIntVector Dimensions;
	float BlockSize;

	UPROPERTY()
	TArray<TObjectPtr<UBitArray>> PlanesData;
};

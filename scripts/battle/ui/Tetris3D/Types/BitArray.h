// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "UObject/Object.h"
#include "BitArray.generated.h"

/**
 * BitArray
 */
UCLASS(BlueprintType)
class TETRIS3D_API UBitArray : public UObject
{
	GENERATED_BODY()

public:
	UBitArray();
	explicit UBitArray(int64 Count);
	
	UFUNCTION(BlueprintCallable)
	void SetAllBits();

	UFUNCTION(BlueprintCallable)
	void ClearAllBits();

	UFUNCTION(BlueprintCallable)
	void SetBit(int64 BitPosition);

	UFUNCTION(BlueprintCallable)
	void ClearBit(int64 BitPosition);

	UFUNCTION(BlueprintCallable)
	bool Get(int64 BitPosition) const;
	
	UFUNCTION(BlueprintCallable)
	void Reset(int64 NewCount);

	UFUNCTION(BlueprintCallable)
	bool AreAllBitsSet() const;

	UFUNCTION(BlueprintCallable)
	bool AreAllBitsCleared() const;

	UFUNCTION(BlueprintCallable)
	int64 GetCount() const { return Count; }

private:
	UPROPERTY()
	TArray<int64> BitNumbers;

	UPROPERTY()
	int64 Count = 64;
};

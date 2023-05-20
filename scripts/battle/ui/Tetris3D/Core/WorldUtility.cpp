// Fill out your copyright notice in the Description page of Project Settings.


#include "WorldUtility.h"

#include "Tetris3D/Types/BitArray.h"

void UWorldUtility::Initialize(const FIntVector& InDimensions, const float InBlockSize, const FVector& InGridWorldOffset)
{
	Dimensions = InDimensions;
	BlockSize = InBlockSize;
	GridWorldOffset = InGridWorldOffset;

	const int PlaneCellNums = Dimensions.X * Dimensions.Y; 
	for(int i=0; i < Dimensions.Z; i++)
	{
		UBitArray* BitMask = NewObject<UBitArray>();
		BitMask->AddToRoot();
		BitMask->Reset(PlaneCellNums);
		PlanesData.Add(BitMask);
	}
}

FVector UWorldUtility::GetWorldPositionFromGridPosition(const FIntVector& GridPosition) const
{
	FVector WorldPosition = FVector(GridPosition) * BlockSize + FVector(BlockSize/2);
	WorldPosition += this->GridWorldOffset;
	return WorldPosition;
}

FIntVector UWorldUtility::GetGridPositionFromWorldPosition(const FVector& WorldPosition) const
{
	const FVector LocalPosition = WorldPosition - FVector(BlockSize/2) - this->GridWorldOffset;
	const FIntVector GridPosition = FIntVector(
		FMath::RoundToInt(LocalPosition.X / BlockSize),
		FMath::RoundToInt(LocalPosition.Y / BlockSize),
		FMath::RoundToInt(LocalPosition.Z / BlockSize)
	);
	return GridPosition;
}

bool UWorldUtility::IsLocationValid(FIntVector BasePosition, TArray<FIntVector> Positions, FIntVector Rotation)
{
	TArray<FIntVector> RotatedPositions;

	// Create rotation matrices for each axis
	FMatrix RotationMatrixX = FRotationMatrix(FRotator(Rotation.X, 0.f, 0.f));
	FMatrix RotationMatrixY = FRotationMatrix(FRotator(0.f, Rotation.Y, 0.f));

	for (const FIntVector& Position : Positions)
	{
		// Apply each rotation matrix in order
		FVector RotatedVector = RotationMatrixY.TransformPosition(RotationMatrixX.TransformPosition(FVector(Position)));
		RotatedPositions.Add(FIntVector(FMath::RoundToInt(RotatedVector.X), FMath::RoundToInt(RotatedVector.Y), FMath::RoundToInt(RotatedVector.Z)));
	}
	
	for (const auto& RotatedPosition : RotatedPositions)
	{
		if(IsInBounds(BasePosition + RotatedPosition) == false || IsOccupied(BasePosition + RotatedPosition))
		{
			return false;
		}
	}
	return true;
}

TArray<FIntVector> UWorldUtility::GetNewLocations(FIntVector BasePosition, TArray<FIntVector> Positions,
	FIntVector Rotation)
{
	TArray<FIntVector> RotatedPositions;

	// Create rotation matrices for each axis
	FMatrix RotationMatrixX = FRotationMatrix(FRotator(Rotation.X, 0.f, 0.f));
	FMatrix RotationMatrixY = FRotationMatrix(FRotator(0.f, Rotation.Y, 0.f));

	RotatedPositions.Add(BasePosition);
	for (const FIntVector& Position : Positions)
	{
		// Apply each rotation matrix in order
		FVector RotatedVector = RotationMatrixY.TransformPosition(RotationMatrixX.TransformPosition(FVector(Position)));
		RotatedPositions.Add(BasePosition + FIntVector(FMath::RoundToInt(RotatedVector.X), FMath::RoundToInt(RotatedVector.Y), FMath::RoundToInt(RotatedVector.Z)));
	}
	
	return RotatedPositions;
}

// bool UWorldUtility::FillPosition(const FIntVector& BlockPosition)
// {
// 	
// }
//
// bool UWorldUtility::FillPosition()
// {
// 	
// }

bool UWorldUtility::IsInBounds(const FIntVector& BlockPosition)
{
	return BlockPosition.X >= 0 && BlockPosition.X < Dimensions.X &&
			BlockPosition.Y >= 0 && BlockPosition.Y < Dimensions.Y &&
				BlockPosition.Z >= 0;
}

bool UWorldUtility::IsOccupied(const FIntVector& BlockPosition)
{
	int ZLocation = BlockPosition.Z;
	if(ZLocation >= Dimensions.Z)
	{
		return false;
	}
	const int BitPos = BlockPosition.Y * Dimensions.X + BlockPosition.X;
	auto Val = PlanesData[ZLocation]->Get(BitPos);
	if(Val == true)
	{
		FString Msg = "Position is Occupied" + BlockPosition.ToString();
		GEngine->AddOnScreenDebugMessage(1, 5.0f, FColor::Red, *Msg);
	}
	return Val;
}

void UWorldUtility::SetFlag(FIntVector Location)
{
	auto PlaneData = PlanesData[Location.Z];
	PlaneData->SetBit(Location.Y * Dimensions.X + Location.X);
}

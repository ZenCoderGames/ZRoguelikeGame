// Fill out your copyright notice in the Description page of Project Settings.


#include "BitArray.h"

UBitArray::UBitArray()
{
	BitNumbers.Add(0);
}

UBitArray::UBitArray(int64 Count)
{
	Reset(Count);
}

void UBitArray::SetAllBits()
{
	for (int64 i = 0; i < BitNumbers.Num(); ++i)
	{
		BitNumbers[i] = ~static_cast<int64>(0);
	}
}

void UBitArray::ClearAllBits()
{
	for (int64 i = 0; i < BitNumbers.Num(); ++i)
	{
		BitNumbers[i] = static_cast<int64>(0);
	}
}

void UBitArray::SetBit(int64 BitPosition)
{
	int64 Index = BitPosition / 64;
	int64 Bit = BitPosition % 64;
	if (Index >= BitNumbers.Num())
	{
		// Todo: Log Error
		return;
	}
	BitNumbers[Index] |= (static_cast<int64>(1) << Bit);
}

void UBitArray::ClearBit(int64 BitPosition)
{
	int64 Index = BitPosition / 64;
	int64 Bit = BitPosition % 64;
	if (Index >= BitNumbers.Num())
	{
		// Todo: Log Error
		return;
	}
	BitNumbers[Index] &= ~(static_cast<int64>(1) << Bit);
}

void UBitArray::Reset(int64 NewCount)
{
	Count = NewCount;
	int64 NumBits = (Count + 63) / 64; // Safer than 1 + (Count-1)/64;
	BitNumbers.SetNum(NumBits, true);
	ClearAllBits();
}

bool UBitArray::Get(int64 BitPosition) const
{
	int64 Index = BitPosition / 64;
	int64 Bit = BitPosition % 64;
	if (Index >= BitNumbers.Num())
	{
		return false;
	}
	return (BitNumbers[Index] & (static_cast<int64>(1) << Bit)) != 0;
}

bool UBitArray::AreAllBitsSet() const
{
	for (int64 i = 0; i < BitNumbers.Num() - 1; ++i)
	{
		if (BitNumbers[i] != ~0)
		{
			return false;
		}
	}
	int64 LastBits = Count % 64;
	if (LastBits == 0)
	{
		return true;
	}
	int64 Mask = (static_cast<int64>(1) << LastBits) - 1;
	return ((BitNumbers.Last() & Mask) == Mask);
}

bool UBitArray::AreAllBitsCleared() const
{
	for (int64 i = 0; i < BitNumbers.Num() - 1; ++i)
	{
		if (BitNumbers[i] != 0)
		{
			return false;
		}
	}
	int64 LastBits = Count % 64;
	if (LastBits == 0)
	{
		return true;
	}
	int64 Mask = (static_cast<int64>(1) << LastBits) - 1;
	return ((BitNumbers.Last() & Mask) == 0);
}

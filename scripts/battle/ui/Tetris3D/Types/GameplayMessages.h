#pragma once

#include "CoreMinimal.h"
#include "Tetris3D/Core/TetrominoPiece.h"
#include "GameplayMessages.generated.h"

USTRUCT(BlueprintType, Blueprintable)
struct FGameplayMessageBase
{
	GENERATED_USTRUCT_BODY()
};

USTRUCT(BlueprintType, Blueprintable)
struct FGameplayMessagePiece
{
	GENERATED_BODY()

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TObjectPtr<ATetrominoPiece> Piece;
};

USTRUCT(BlueprintType, Blueprintable)
struct FGameplayMessageStatus
{
	GENERATED_USTRUCT_BODY()

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FString StatusText;
};

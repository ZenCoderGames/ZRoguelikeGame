// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Core/WorldUtility.h"
#include "GameFramework/GameplayMessageSubsystem.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "Types\GameplayMessages.h"
#include "TetrisGameplayStatics.generated.h"

/**
 * 
 */
UCLASS()
class TETRIS3D_API UTetrisGameplayStatics : public UBlueprintFunctionLibrary
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintCallable, Category="Tetris3D|Messages")
	static bool SendGameplayMessage(const UObject* WorldContextObject, FGameplayTag InTag, const FGameplayMessageBase& InMessage);

	UFUNCTION(BlueprintCallable, Category="Tetris3D|Messages")
	static UWorldUtility* GetWorldUtility(const UObject* WorldContextObject);
};

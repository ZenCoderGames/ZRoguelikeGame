// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/HUD.h"
#include "TetrisGameHUD.generated.h"

UCLASS()
class TETRIS3D_API ATetrisGameHUD : public AHUD
{
	GENERATED_BODY()

public:
	// Sets default values for this actor's properties
	ATetrisGameHUD();

	UFUNCTION(BlueprintImplementableEvent, meta=(DisplayName = "On Initialize"))
	void BP_Initialize();
	
	void Initialize();
};

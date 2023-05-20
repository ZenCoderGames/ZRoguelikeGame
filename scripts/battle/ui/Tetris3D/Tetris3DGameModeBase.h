// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "AbilitySystemInterface.h"
#include "Abilities/TetrisAttributeSet.h"
#include "Core/TetrominoSpawner.h"
#include "Core/WorldUtility.h"
#include "Core/Config/Tetris3DGameConfig.h"
#include "GameFramework/GameModeBase.h"
#include "Types/GameplayMessages.h"
#include "Tetris3DGameModeBase.generated.h"

/**
 * 
 */
UCLASS()
class TETRIS3D_API ATetris3DGameModeBase : public AGameModeBase, public IAbilitySystemInterface
{
	GENERATED_BODY()

public:
	ATetris3DGameModeBase();

	UFUNCTION(BlueprintImplementableEvent, meta=(DisplayName = "On Initialize"))
	void BP_Initialize();
	
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D")
	TObjectPtr<UTetris3DGameConfig> GameConfig;

	UPROPERTY(BlueprintReadOnly, Category="Tetris|Abilities")
	TObjectPtr<UAbilitySystemComponent> AbilitySystemComponent;

	UFUNCTION(BlueprintCallable, Category="Tetris|Abilities")
	FGameplayAbilitySpecHandle AcquireAbility(TSubclassOf<UGameplayAbility> InAbility);
	
	UPROPERTY(BlueprintReadOnly, Category="Tetris|Abilities")
	TObjectPtr<UTetrisAttributeSet> AttributeSetComponent;

	UPROPERTY(BlueprintReadOnly, Category = "Tetris3D")
	TObjectPtr<UWorldUtility> WorldUtility;
	
	UPROPERTY(BlueprintReadOnly, Category = "Tetris3D")
	TObjectPtr<ATetrominoSpawner> TetrominoSpawner;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D")
	FVector GridWorldOffset;

protected:
	virtual void BeginPlay() override;
	virtual void Tick(float DeltaSeconds) override;
	virtual UAbilitySystemComponent* GetAbilitySystemComponent() const override;
	virtual void PostInitializeComponents() override;
	
private:
	void InitializeGame();
	void OnFallSpeedChange(const FOnAttributeChangeData& FallSpeed);
	void TetrisGameTick();
	void OnTetrominoStopped(FGameplayTag GameplayTag, const FGameplayMessagePiece& MessageData);
	
	float ElapsedTime = 0.0f;
	float TickFrequency = 1.0f;
};

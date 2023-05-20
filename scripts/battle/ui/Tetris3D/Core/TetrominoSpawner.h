// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "BlockBase.h"
#include "WorldUtility.h"
#include "Config/Tetris3DGameConfig.h"
#include "GameFramework/Actor.h"
#include "TetrominoSpawner.generated.h"

class ATetrominoPiece;

UCLASS()
class TETRIS3D_API ATetrominoSpawner : public AActor
{
	GENERATED_BODY()

public:
	// Sets default values for this actor's properties
	ATetrominoSpawner();
	
	UFUNCTION(BlueprintCallable, Category = "Tetris3D")
	void SpawnTetrominoPiece();

	UFUNCTION(BlueprintImplementableEvent, meta=(DisplayName = "On Initialize"))
	void BP_Initialize();

	// CPP Only
	void Initialize(TObjectPtr<UTetris3DGameConfig> InGameConfig, TObjectPtr<UWorldUtility> InWorldUtility);

	UFUNCTION()
	bool MovePiece();

	UFUNCTION()
	void Replace();

	// Properties
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D")
	TObjectPtr<UTetris3DGameConfig> GameConfig;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D")
	TSubclassOf<ATetrominoPiece> TetrominoClass;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D")
	TSubclassOf<ABlockBase> BaseBlockClass;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D")
	FIntVector GridLocation;
	
	UPROPERTY(BlueprintReadWrite, Category = "Tetris3D")
	TObjectPtr<ATetrominoPiece> CurrentPiece;

	UPROPERTY(BlueprintReadWrite, Category = "Tetris3D")
	TObjectPtr<ATetrominoPiece> NextPiece;

	UPROPERTY(BlueprintReadOnly, Category = "Tetris3D")
	TObjectPtr<UWorldUtility> WorldUtility;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D")
	TObjectPtr<AActor> SpawnLocation;

private:
	float GetTotalRatio() const;
	void CreateNextTetromino(float TotalRatio);
};

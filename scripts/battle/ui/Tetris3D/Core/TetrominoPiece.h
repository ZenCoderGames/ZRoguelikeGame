// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "BlockComponent.h"
#include "Config/TetrominoConfig.h"
#include "GameFramework/Actor.h"
#include "TetrominoPiece.generated.h"

class ATetris3DGameModeBase;

UCLASS()
class TETRIS3D_API ATetrominoPiece : public AActor
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintCallable, Category="Tetris3D")
	void GenerateBlocks();
	void SetWorldPosition() const;

	void Init(UTetrominoConfig* Key, FIntVector IntVector);

	// Sets default values for this actor's properties
	ATetrominoPiece();

protected:
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;

public:
	// Called every frame
	virtual void Tick(float DeltaTime) override;

	UFUNCTION(BlueprintCallable, Category = "Tetris3D")
	bool Translate(FIntVector Location);

	UFUNCTION(BlueprintCallable, Category = "Tetris3D")
	void Rotate(bool X, bool Y);

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D")
	TSubclassOf<UBlockComponent> BlockComponentClass;
	
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D")
	TObjectPtr<UTetrominoConfig> TetrominoConfig;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Tetris3D")
	FIntVector Rotation = FIntVector(0);

	FIntVector GridPos;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	bool Stopped;
	
	// UPROPERTY()
	// TObjectPtr<UWorldUtility> WorldUtility;

private:

	TArray<TObjectPtr<UBlockComponent>> BlockComponents;

	void AddBlockComponent(const FIntVector& Location);
};

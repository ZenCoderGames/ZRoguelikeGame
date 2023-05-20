// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Pawn.h"
#include "AbilitySystemInterface.h"
#include "GameplayTagContainer.h"
#include "Tetris3D/Types/GameplayMessages.h"
#include "GameRoomPawn.generated.h"

UCLASS()
class TETRIS3D_API AGameRoomPawn : public APawn, public IAbilitySystemInterface
{
	GENERATED_BODY()

public:
	// Sets default values for this pawn's properties
	AGameRoomPawn();

	UFUNCTION(BlueprintImplementableEvent, meta=(DisplayName = "On Initialize"))
	void BP_Initialize();

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly)
	USceneComponent* DefaultSceneRoot;
	
	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	UStaticMeshComponent* Ground;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	UStaticMeshComponent* LeftWall;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	UStaticMeshComponent* RightWall;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	UStaticMeshComponent* FrontWall;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	UStaticMeshComponent* BackWall;

	/** Follow camera */
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = Camera, meta = (AllowPrivateAccess = "true"))
	class UCameraComponent* FollowCamera;

	UPROPERTY(BlueprintReadOnly)
	TObjectPtr<UAbilitySystemComponent> AbilitySystemComponent;

	UPROPERTY()
	TObjectPtr<ATetrominoPiece> ActivePiece;

protected:
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;
	virtual UAbilitySystemComponent* GetAbilitySystemComponent() const override;
public:
	// Called every frame
	virtual void Tick(float DeltaTime) override;

	// Called to bind functionality to input
	virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

	void InitRoom(const FIntVector& InDimensions, TObjectPtr<UAbilitySystemComponent> InASC);

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Tetris3D")
	FIntVector Dimensions;

private:
	void OnNewPieceSpawn(FGameplayTag GameplayTag, const FGameplayMessagePiece& MessageData);
};

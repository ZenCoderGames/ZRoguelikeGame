// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Pawn.h"
#include "Camera/CameraComponent.h"
#include "GameRoom.generated.h"

UCLASS()
class TETRIS3D_API AGameRoom : public APawn
{
	GENERATED_BODY()

public:
	// Sets default values for this pawn's properties
	AGameRoom();

protected:
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;

public:
	// Called every frame
	virtual void Tick(float DeltaTime) override;

	// Called to bind functionality to input
	virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;
	void InitRoom(int32 INT32, int32 Breadth, int32 Height);

	//Input Actions

	//Camera Controls Actions
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = Input, meta = (AllowPrivateAccess = "true"))
	class UInputAction* MoveCameraRight;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = Input, meta = (AllowPrivateAccess = "true"))
	class UInputAction* MoveCameraLeft;


	//Input Functions
	void CameraRight();

	void CameraLeft();


	//Room Properties
	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	FVector Room_Dimensions;

	UPROPERTY(BlueprintReadOnly)
	FVector RoomCenter;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	USceneComponent* LTCamera;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	USceneComponent* LBCamera;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	USceneComponent* RTCamera;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	USceneComponent* RBCamera;

	UPROPERTY(BlueprintReadOnly)
	TArray<USceneComponent*> CameraLocations;

	int CurrentCameraIndex = 0;

	//Room Static Meshes & Camera

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Camera)
	UCameraComponent* CameraComponent;

	UPROPERTY()
	FVector CurrentCameraLocation;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	UStaticMeshComponent* GroundMesh;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	UStaticMeshComponent* LeftWall;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	UStaticMeshComponent* RightWall;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	UStaticMeshComponent* TopWall;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	UStaticMeshComponent* BottomWall;


	//experiment

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	class UInstancedStaticMeshComponent* Floor;

	UPROPERTY(EditDefaultsOnly, BlueprintReadWrite)
	class UInstancedStaticMeshComponent* Wall;

	
	UPROPERTY()
	FTransform CachedTransform1;

	UPROPERTY()
	FTransform CachedTransform2;

	int32 CurrentWallInvisibilityIndex = 0;

	void ChangeWallsVisibility();
};

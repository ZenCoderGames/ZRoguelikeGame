// Fill out your copyright notice in the Description page of Project Settings.


#include "GameRoom.h"
#include "Components/InputComponent.h"
#include "EnhancedInputComponent.h"
#include "Components/InstancedStaticMeshComponent.h"

// Sets default values
AGameRoom::AGameRoom()
{
 	// Set this pawn to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;


	Floor = CreateDefaultSubobject<UInstancedStaticMeshComponent>(TEXT("Floor"));
	Wall = CreateDefaultSubobject<UInstancedStaticMeshComponent>(TEXT("Wall"));
	Floor->SetupAttachment(RootComponent);
	//GroundMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("GroundMesh"));
	//SetRootComponent(GroundMesh);
	////USceneComponent* RootComponent = GetRootComponent();
	//LeftWall = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("LeftWall"));
	//LeftWall->SetupAttachment(RootComponent);
	//RightWall = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("RightWall"));
	//RightWall->SetupAttachment(RootComponent);
	//TopWall = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("TopWall"));
	//TopWall->SetupAttachment(RootComponent);
	//BottomWall = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("BottomWall"));
	//BottomWall->SetupAttachment(RootComponent);
	LTCamera = CreateDefaultSubobject<USceneComponent>(TEXT("LTCamera"));
	LTCamera->AttachToComponent(RootComponent, FAttachmentTransformRules::KeepRelativeTransform);
	LBCamera = CreateDefaultSubobject<USceneComponent>(TEXT("LBCamera"));
	LBCamera->AttachToComponent(RootComponent, FAttachmentTransformRules::KeepRelativeTransform);
	RTCamera = CreateDefaultSubobject<USceneComponent>(TEXT("RTCamera"));
	RTCamera->AttachToComponent(RootComponent, FAttachmentTransformRules::KeepRelativeTransform);
	RBCamera = CreateDefaultSubobject<USceneComponent>(TEXT("RBCamera"));
	RBCamera->AttachToComponent(RootComponent, FAttachmentTransformRules::KeepRelativeTransform);

	CameraComponent = CreateDefaultSubobject<UCameraComponent>(TEXT("CameraComponent"));
	//CameraComponent->SetupAttachment(RootComponent);
	CameraComponent->SetFieldOfView(90.0f);

	//GroundMesh->SetWorldScale3D(FVector(Room_Dimensions.X, 1, Room_Dimensions.Y));
	//RoomCenter = FVector(0, 0, Room_Dimensions.Z / 2);






	//CameraLocations.Add(RBCamera);
	//CameraLocations.Add(RTCamera);
	//CameraLocations.Add(LTCamera);
	//CameraLocations.Add(LBCamera);


}

// Called when the game starts or when spawned
void AGameRoom::BeginPlay()
{
	Super::BeginPlay();
	
	
}

// Called every frame
void AGameRoom::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

}

// Called to bind functionality to input
void AGameRoom::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	//Super::SetupPlayerInputComponent(PlayerInputComponent);

	if (UEnhancedInputComponent* EnhancedInputComponent = CastChecked<UEnhancedInputComponent>(PlayerInputComponent)) {

		//Jumping
		EnhancedInputComponent->BindAction(MoveCameraLeft, ETriggerEvent::Triggered, this, &AGameRoom::CameraLeft);
		EnhancedInputComponent->BindAction(MoveCameraRight, ETriggerEvent::Triggered, this, &AGameRoom::CameraRight);
	}
}

void AGameRoom::InitRoom(int32 Length, int32 Breadth, int32 Height)
{
	Room_Dimensions = FVector(Length, Breadth, Height);
	RoomCenter = FVector(0, 0, Room_Dimensions.Z / 2);
	
	CurrentCameraLocation = RBCamera->GetComponentLocation();
	CameraComponent->SetWorldLocation(CurrentCameraLocation);

	int RoomFloorsX = Room_Dimensions.X;
	int RoomFloorsY = Room_Dimensions.Y;

	FVector Translation(0.0f, 0.0f, 0.0f);
	FRotator Rotation(0.0f, 0.0f, 0.0f);
	FVector Scale(RoomFloorsX, RoomFloorsY, 2.0f);

	FTransform MyTransform(Rotation, Translation, Scale);

	Floor->AddInstance(MyTransform);


	FVector Translation1((RoomFloorsX+1) * 50, 0.0f, 0.0f);
	FRotator Rotation1(0.0f, 0.0f, 0.0f);
	FVector Scale1(1.0f, RoomFloorsY, Room_Dimensions.Z);

	FTransform MyTransform1(Rotation1, Translation1, Scale1);

	Wall->AddInstance(MyTransform1);

	FVector Translation2(-(RoomFloorsX + 1) * 50, 0.0f, 0.0f);
	FRotator Rotation2(0.0f, 0.0f, 0.0f);
	FVector Scale2(1.0f, RoomFloorsY, Room_Dimensions.Z);

	FTransform MyTransform2(Rotation2, Translation2, Scale2);

	Wall->AddInstance(MyTransform2);


	FVector Translation3(0.0f, (RoomFloorsY + 1) * 50, 0.0f);
	FRotator Rotation3(0.0f, 0.0f, 0.0f);
	FVector Scale3(RoomFloorsX, 1.0f, Room_Dimensions.Z);

	FTransform MyTransform3(Rotation3, Translation3, Scale3);

	Wall->AddInstance(MyTransform3);

	FVector Translation4(0.0f, -(RoomFloorsY + 1) * 50, 0.0f);
	FRotator Rotation4(0.0f, 0.0f, 0.0f);
	FVector Scale4(RoomFloorsX, 1.0f, Room_Dimensions.Z);

	FTransform MyTransform4(Rotation4, Translation4, Scale4);

	Wall->AddInstance(MyTransform4);

	FVector CameraDirection = RoomCenter - RBCamera->GetComponentLocation();;
	FQuat CameraRotation = CameraDirection.Rotation().Quaternion();
	CameraComponent->SetWorldRotation(CameraRotation);

	FTransform FirstWall;
	FTransform SecondWall;


	//Make Sure the first two walls are correct 
	Wall->GetInstanceTransform(CurrentCameraIndex, FirstWall);
	
	CachedTransform1 = FirstWall;

	//FirstWall.SetScale3D(FVector::ZeroVector);
	Wall->UpdateInstanceTransform(CurrentCameraIndex, FTransform(FRotator(0, 0, 0), FVector(0, 0, 0), FVector(0, 0, 0)));

	Wall->GetInstanceTransform(CurrentCameraIndex+1, SecondWall);

	CachedTransform2 = SecondWall;
	Wall->UpdateInstanceTransform(CurrentCameraIndex+1, FTransform(FRotator(0, 0, 0), FVector(0, 0, 0), FVector(0, 0, 0)));
	//SecondWall.SetScale3D(FVector::ZeroVector);
	//GroundMesh->SetWorldScale3D(FVector(Room_Dimensions.X, Room_Dimensions.Y, 1.0f));
	//LeftWall->SetWorldScale3D(FVector(1.0f, Room_Dimensions.Y, Room_Dimensions.Z));
	//RightWall->SetWorldScale3D(FVector(1.0f, Room_Dimensions.Y, Room_Dimensions.Z));
	//TopWall->SetWorldScale3D(FVector(Room_Dimensions.X, 1.0f, Room_Dimensions.Z));
	//BottomWall->SetWorldScale3D(FVector(Room_Dimensions.X, 1.0f, Room_Dimensions.Z));

	//// Position the walls based on the dimensions
	//LeftWall->SetWorldLocation(FVector(-(Room_Dimensions.X + 1) / 2.0f, 0.0f, 0.0f));
	//RightWall->SetWorldLocation(FVector((Room_Dimensions.X + 1) / 2.0f, 0.0f, 0.0f));
	//TopWall->SetWorldLocation(FVector(0.0f, (Room_Dimensions.Y + 1) / 2.0f, 0.0f));
	//BottomWall->SetWorldLocation(FVector(0.0f, -(Room_Dimensions.Y + 1) / 2.0f, 0.0f));
}

void AGameRoom::CameraRight()
{

	CurrentCameraIndex++;
	if (CurrentCameraIndex >= CameraLocations.Num())
	{
		CurrentCameraIndex = 0;
	}
	ChangeWallsVisibility();
	CurrentCameraLocation = CameraLocations[CurrentCameraIndex]->GetComponentLocation();
	CameraComponent->SetWorldLocation(CurrentCameraLocation);

	FVector CameraDirection = RoomCenter - CameraLocations[CurrentCameraIndex]->GetComponentLocation();;
	FQuat CameraRotation = CameraDirection.Rotation().Quaternion();
	CameraComponent->SetWorldRotation(CameraRotation);
}

void AGameRoom::CameraLeft()
{
	CurrentCameraIndex--;
	if (CurrentCameraIndex < 0)
	{
		CurrentCameraIndex = CameraLocations.Num()-1;
	}
	ChangeWallsVisibility();
	CurrentCameraLocation = CameraLocations[CurrentCameraIndex]->GetComponentLocation();
	CameraComponent->SetWorldLocation(CurrentCameraLocation);

	FVector CameraDirection = RoomCenter - CameraLocations[CurrentCameraIndex]->GetComponentLocation();;
	FQuat CameraRotation = CameraDirection.Rotation().Quaternion();
	CameraComponent->SetWorldRotation(CameraRotation);
}

void AGameRoom::ChangeWallsVisibility()
{
	FTransform FirstWall;
	FTransform SecondWall;
	FTransform PreviousWall;

	Wall->GetInstanceTransform(CurrentCameraIndex-1, PreviousWall);
    
	Wall->UpdateInstanceTransform(CurrentCameraIndex - 1, CachedTransform1);

	Wall->GetInstanceTransform(CurrentCameraIndex, FirstWall);
	CachedTransform1 = FirstWall;

	Wall->UpdateInstanceTransform(CurrentCameraIndex, FTransform(FRotator(0, 0, 0), FVector(0, 0, 0), FVector(0, 0, 0)));

	if (CurrentCameraIndex + 1 >= CameraLocations.Num())
	{
		Wall->GetInstanceTransform(0, SecondWall);
		Wall->UpdateInstanceTransform(CurrentCameraIndex + 1, FTransform(FRotator(0, 0, 0), FVector(0, 0, 0), FVector(0, 0, 0)));
	}
	else 
	{ 
		Wall->GetInstanceTransform(CurrentCameraIndex + 1, SecondWall); 
		Wall->UpdateInstanceTransform(0, FTransform(FRotator(0, 0, 0), FVector(0, 0, 0), FVector(0, 0, 0)));
	}

	CachedTransform2 = SecondWall;

}


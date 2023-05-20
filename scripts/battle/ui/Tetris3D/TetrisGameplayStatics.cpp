// Fill out your copyright notice in the Description page of Project Settings.


#include "TetrisGameplayStatics.h"

#include "Tetris3DGameModeBase.h"
#include "Kismet/GameplayStatics.h"

bool UTetrisGameplayStatics::SendGameplayMessage(const UObject* WorldContextObject, FGameplayTag InTag, const FGameplayMessageBase& InMessage)
{
	if(WorldContextObject == nullptr)
	{
		return false;
	}
	UGameplayMessageSubsystem& MessageSystem = UGameplayMessageSubsystem::Get(WorldContextObject);
	MessageSystem.BroadcastMessage(InTag, InMessage);
	return true;
}

UWorldUtility* UTetrisGameplayStatics::GetWorldUtility(const UObject* WorldContextObject)
{
	if(const auto GameMode = Cast<ATetris3DGameModeBase>(UGameplayStatics::GetGameMode(WorldContextObject)))
	{
		return GameMode->WorldUtility;
	};
	return nullptr;
}

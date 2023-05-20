// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "AttributeSet.h"
#include "AbilitySystemComponent.h"
#include "TetrisAttributeSet.generated.h"

/**
 * 
 */

// TODO: Find a better place to have the macros
#define ATTRIBUTE_ACCESSORS_ALL(CName, PName) \
GAMEPLAYATTRIBUTE_PROPERTY_GETTER(CName, PName) \
GAMEPLAYATTRIBUTE_VALUE_GETTER(PName) \
GAMEPLAYATTRIBUTE_VALUE_SETTER(PName) \
GAMEPLAYATTRIBUTE_VALUE_INITTER(PName)

UCLASS()
class TETRIS3D_API UTetrisAttributeSet : public UAttributeSet {
	GENERATED_BODY()

public:
	UTetrisAttributeSet();

	//virtual void PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue) override;
	virtual void PreAttributeBaseChange(const FGameplayAttribute& Attribute, float& NewValue) const override;
	//virtual void PostGameplayEffectExecute(const FGameplayEffectModCallbackData& Data) override;

protected:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Echo|GAS")
	FGameplayAttributeData FallSpeed;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Echo|GAS")
	FGameplayAttributeData MaxFallSpeed;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Echo|GAS")
	FGameplayAttributeData ScoreMultiplier;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Echo|GAS")
	FGameplayAttributeData Score;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Echo|GAS")
	FGameplayAttributeData FancyResource;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Echo|GAS")
	FGameplayAttributeData MaxFancyResource;

public: // Getters & Accessors
	ATTRIBUTE_ACCESSORS_ALL(UTetrisAttributeSet, FallSpeed)
	ATTRIBUTE_ACCESSORS_ALL(UTetrisAttributeSet, MaxFallSpeed)
	ATTRIBUTE_ACCESSORS_ALL(UTetrisAttributeSet, ScoreMultiplier)
	ATTRIBUTE_ACCESSORS_ALL(UTetrisAttributeSet, Score) // Review: Ideally, shouldn't be in Attribute Set? Why?
	ATTRIBUTE_ACCESSORS_ALL(UTetrisAttributeSet, FancyResource)
	ATTRIBUTE_ACCESSORS_ALL(UTetrisAttributeSet, MaxFancyResource)
};
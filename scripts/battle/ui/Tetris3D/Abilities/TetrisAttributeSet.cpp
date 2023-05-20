// Fill out your copyright notice in the Description page of Project Settings.


#include "TetrisAttributeSet.h"

UTetrisAttributeSet::UTetrisAttributeSet(): FallSpeed(0.5f), MaxFallSpeed(1.0f), ScoreMultiplier(1.0f), Score(0.0f), FancyResource(0.0f), MaxFancyResource(3.0f) 
{
	
}

void UTetrisAttributeSet::PreAttributeBaseChange(const FGameplayAttribute& Attribute, float& NewValue) const
{
	if(Attribute == GetFallSpeedAttribute())
	{
		NewValue = FMath::Clamp(NewValue, 0.0f, GetMaxFallSpeed());
	}
	if(Attribute == GetFancyResourceAttribute())
	{
		NewValue = FMath::Clamp(NewValue, 0.0f, GetMaxFancyResource());
	}
	Super::PreAttributeBaseChange(Attribute, NewValue);	
}

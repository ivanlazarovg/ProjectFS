using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class DayNightCycle : MonoBehaviour
{
    [SerializeField]
    public float timeDayLength = 0.5f; // the length of a whole cycle

    [SerializeField]
    [Range(0f, 1f)]
    public float timeOfDay; // current daytime

    [SerializeField]
    private float dayCounter; // days passed
    
    [SerializeField]
    bool isPaused = false; // checks if the game is paused

    public Transform SunRotation; // the object the sun rotates around(because it is his parent object and it's relative to its axis)

    public float sunBaseIntensity = 1.20f; // base intensity of our sun

    [SerializeField]
    private Gradient sunGradient;

    [SerializeField]
    private Gradient ambientGradient;

    [SerializeField]
    private Gradient topSkyGradient;

    [SerializeField]
    private Gradient middleSkyGradient;

    [SerializeField]
    private Gradient horizonGradient;

    [SerializeField]
    private Gradient horizonColorGradient;

    [SerializeField]
    private Gradient sunColorGradient;

    [SerializeField]
    private Gradient waterEdgeGradient;

    [SerializeField]
    private Gradient ambientEquatorGradient;

    [SerializeField]
    private Gradient ambientGroundGradient;

    [SerializeField]
    private Gradient fogGradient;

    [SerializeField]
    private Gradient CloudTopGradient;

    [SerializeField]
    private Gradient CloudBottomGradient;

    [SerializeField]
    private Gradient waterColorGradient;

    [SerializeField]
    private AnimationCurve horizonSharpnessCurve;

    [SerializeField]
    private AnimationCurve sunGlowIntensityCurve;

    [SerializeField]
    private AnimationCurve sunRadiusIntensityCurve;

    [SerializeField]
    private AnimationCurve starIntensityCurve;

    [SerializeField]
    private AnimationCurve moonIntensityCurve;

    [SerializeField]
    private AnimationCurve skyPowerCurve;

    [SerializeField]
    private AnimationCurve horizonGlowCurve;

    [SerializeField]
    private AnimationCurve horizonMaxCurve;

    [SerializeField]
    private AnimationCurve normalScaleCurve;

    [SerializeField]
    private float sunVariation = 1f;

    private float timeScale = 100f;

    [SerializeField]
    private float sunRisePoint = 0.07f;

    [SerializeField]
    private float sunSetPoint = 0.715f;

    [SerializeField]
    private float sunRiseInterpolationValue;

    [SerializeField]
    private float sunSetInterpolationValue;

    public Light sun;

    private bool isLerpingSunSet = false;

    private bool isLerpingSunRise = false;

    private float sunRiseInterpolation;

    private float sunSetInterpolation;

    [SerializeField]
    private Material skyboxmat;

    [SerializeField]
    private Material sunglowmat;

    [SerializeField]
    private Material riverMat;

    private float regulationAmount;

    private float timer;

    private float cloudCoverage;

    private bool cloudIsOn;

    [SerializeField]
    private Material cloudMat;

    [SerializeField]
    private float lerpSpeed;

    private bool isLerping = false;

    private float targetLerp;

    [SerializeField]
    private float randomValueLimit;

    private float cloudCoverageTarget;

    [SerializeField]
    private float waitTime;

    private Coroutine CloudCoroutine;

    private void Start()
    {
        //set the sun base intensity
        sun.intensity = sunBaseIntensity;
        cloudCoverage = cloudMat.GetFloat("_CloudCoverage");
        
    }
    private void Update()
    {
        
        
        if (Input.GetKeyDown(KeyCode.P))
        {
            isPaused = !isPaused;
        }
        if (!isPaused)
        {

            if (!cloudIsOn )
            {
                CloudCoroutine = StartCoroutine(CloudCoverageAdjust());
            }

            float t = 0f;
            t += Time.deltaTime * lerpSpeed;
            cloudMat.SetFloat("_CloudCoverage", Mathf.Lerp(cloudMat.GetFloat("_CloudCoverage"), cloudCoverageTarget, t));

            TimeScaling();

            #region SunIntensityInterpolationSettings

            //the timeOfDay value the sunrise interpolation starts at
            sunRiseInterpolationValue = 0.12f;

            //the sunrise interpolation which smoothly increases the sun intensity and is relative to the time of day
            sunRiseInterpolation = (timeOfDay - sunRisePoint) * (1 / (sunRiseInterpolationValue - sunRisePoint));

            //the timeOfDay value the sunset interpolation starts at
            sunSetInterpolationValue = 0.64f;

            //the sunset interpolation which smoothly decreases(look below to see why) the sun intensity and is relative to the time of day
            sunSetInterpolation = (timeOfDay - sunSetInterpolationValue) * (1 / (sunSetPoint - sunSetInterpolationValue - 0.020f));

            #endregion

            //Find the current time of day
            timeOfDay += Time.deltaTime * timeScale / 86400;
            if (timeOfDay > 1)
            {
                timeOfDay -= 1;
                dayCounter++;
            }

            SunIntensity();
            ColourAdjustment();
            AmbientAdjustment();
            TopSkySet();
            MiddleSkySet();
            HorizonSet();
            SunColorSet();
            SunGlowIntensitySet();
            StarLayersInterpolation();
            MoonIntensitySet();
            RiverEdgeSet();
            FogSet();
            CloudColorSet();
            NormalScaleSet();
            WaterColorSet();
        }
        dailySunRotation();
        
    }


    #region Automatic Cloud Coverage Regulation

    IEnumerator CloudCoverageAdjust()
    {     
        cloudCoverage = cloudMat.GetFloat("_CloudCoverage");
        cloudIsOn = true;
        yield return new WaitForSeconds(waitTime);
        float randomNum = UnityEngine.Random.Range(-randomValueLimit, randomValueLimit);

        cloudCoverageTarget = Mathf.Clamp(cloudCoverage + randomNum, 0f, 0.33f);

        cloudIsOn = false;
        yield return cloudCoverageTarget;
        
    }

    #endregion

    //Convert to real time through scalling
    private void TimeScaling()
    {
        timeScale = 24 / (timeDayLength / 60);
    }

    private void dailySunRotation()
    {
        //calculate the angle of the sun through the time of the current day
        float sunAngle = timeOfDay * 360; 
        //rotate the y axis of the rotation parent object using the sunAngle variable, which will rotate the sun around it
        SunRotation.transform.localRotation = Quaternion.Euler(0f, 0f, sunAngle);
        
    }

    private void SunIntensity()
    {
        #region sunIntensityInterpolation

        sunVariation = 1;

        // basically makes the sun emit no light at night

        if (timeOfDay <= sunRisePoint || timeOfDay >= sunSetPoint)
        {
            sunVariation = 0f;
        }

        else if (timeOfDay <= sunRiseInterpolationValue)
        {
            sunVariation = Mathf.Clamp01(sunRiseInterpolation);

        }
        // essentially the same thing, but for the sunset and in reverse
        else if (timeOfDay >= sunSetInterpolationValue)
        {
            sunVariation = Mathf.Clamp(1 - sunSetInterpolation, -0.1f, 1f);
            isLerpingSunSet = true;
            isLerpingSunRise = false;

        }
        if (timeOfDay > 0.10f && timeOfDay <= sunRiseInterpolationValue + 0.3f)
        {
            isLerpingSunRise = true;
            isLerpingSunSet = false;
        }


        #endregion

        //calculate and set the sun intensity using the two variables we've already initialized
        sun.intensity = sunBaseIntensity * sunVariation;

    }

    #region SunAndAmbientColourAdjustments
    // sets the colour gama of sunrises and sunsets(basically the whole sun)
    private void ColourAdjustment()
    {
        sun.color = sunGradient.Evaluate(timeOfDay);
    }

    private void AmbientAdjustment()
    {
        RenderSettings.ambientSkyColor = ambientGradient.Evaluate(timeOfDay);
        RenderSettings.ambientEquatorColor = ambientEquatorGradient.Evaluate(timeOfDay);
        RenderSettings.ambientGroundColor = ambientGroundGradient.Evaluate(timeOfDay);
    }

    private void TopSkySet()
    {
        skyboxmat.SetColor("_SkyColor4",  topSkyGradient.Evaluate(timeOfDay));
    }

    private void MiddleSkySet()
    {
        skyboxmat.SetColor("_SkyColor2", middleSkyGradient.Evaluate(timeOfDay));
    }

    private void RiverEdgeSet()
    {
        riverMat.SetColor("_WaterEdgeClamp", waterEdgeGradient.Evaluate(timeOfDay));
    }

    private void HorizonSet()
    {
        skyboxmat.SetColor("_HorizonColor", horizonGradient.Evaluate(timeOfDay));
        skyboxmat.SetColor("_HorizonLineColor", horizonColorGradient.Evaluate(timeOfDay));
        skyboxmat.SetFloat("_HorizonSharpness", horizonSharpnessCurve.Evaluate(timeOfDay));
        skyboxmat.SetFloat("_HorizonGlowIntensity", horizonGlowCurve.Evaluate(timeOfDay));
        skyboxmat.SetFloat("_HorizonSunGlowSpreadMax", horizonMaxCurve.Evaluate(timeOfDay));
        skyboxmat.SetFloat("_SkyGradientPower", skyPowerCurve.Evaluate(timeOfDay));
    }

    private void SunColorSet()
    {
        sunglowmat.SetColor("_SunColor", sunColorGradient.Evaluate(timeOfDay));
    }

    private void SunGlowIntensitySet()
    {
        sunglowmat.SetFloat("_SunIntensity", sunGlowIntensityCurve.Evaluate(timeOfDay));
        sunglowmat.SetFloat("_SunRadius", sunRadiusIntensityCurve.Evaluate(timeOfDay));
    }

    private void StarLayersInterpolation()
    {
        skyboxmat.SetFloat("_StarLayer1Intensity", starIntensityCurve.Evaluate(timeOfDay));
        skyboxmat.SetFloat("_StarLayer2Intensity", starIntensityCurve.Evaluate(timeOfDay));
        skyboxmat.SetFloat("_StarLayer3Intensity", starIntensityCurve.Evaluate(timeOfDay));
    }

    private void MoonIntensitySet()
    {
        skyboxmat.SetFloat("_MoonOpacity", moonIntensityCurve.Evaluate(timeOfDay));
    }

    private void NormalScaleSet()
    {
        riverMat.SetFloat("_NormalScale", normalScaleCurve.Evaluate(timeOfDay));
    }

    private void WaterColorSet()
    {
        riverMat.SetColor("_WaterColor", waterColorGradient.Evaluate(timeOfDay));
    }

    private void FogSet()
    {
        RenderSettings.fogColor = fogGradient.Evaluate(timeOfDay);
    }

    private void CloudColorSet()
    {
        cloudMat.SetColor("_CloudColor", CloudTopGradient.Evaluate(timeOfDay));
        cloudMat.SetColor("_normalfalloffcolor", CloudBottomGradient.Evaluate(timeOfDay));
    }

    #endregion

}
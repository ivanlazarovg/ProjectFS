using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class MissileModeUI : MonoBehaviour
{
    public int id;
    public TextMeshProUGUI textMesh;
    public Image image;

    private void Start()
    {
        textMesh = GetComponentInChildren<TextMeshProUGUI>();
        image = GetComponent<Image>();
    }
    public void SetColor(Color color)
    {
        image.color = color;
    }
}

using UnityEngine;

public class TouchInputBridge : MonoBehaviour
{
    public PlayerController2D controller;
    public PlayerCombat combat;

    private float _moveAxis;

    private void Update()
    {
        if (controller != null)
        {
            controller.MoveInput = _moveAxis;
        }
    }

    public void OnMoveLeftDown()
    {
        _moveAxis = -1f;
    }

    public void OnMoveRightDown()
    {
        _moveAxis = 1f;
    }

    public void OnMoveReleased()
    {
        _moveAxis = 0f;
    }

    public void OnJumpPressed()
    {
        if (controller != null)
        {
            controller.JumpPressed = true;
        }
    }

    public void OnAttackPressed()
    {
        if (combat != null)
        {
            combat.AttackPressed = true;
        }
    }
}

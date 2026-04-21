using UnityEngine;

public class PlayerController2D : MonoBehaviour
{
    [Header("Move")]
    public float moveSpeed = 6f;
    public float jumpForce = 12f;

    [Header("Ground Check")]
    public Transform groundCheck;
    public float groundCheckRadius = 0.15f;
    public LayerMask groundLayer;

    public float MoveInput { get; set; }
    public bool JumpPressed { get; set; }

    private Rigidbody2D _rb;
    private bool _isGrounded;
    private bool _facingRight = true;

    private void Awake()
    {
        _rb = GetComponent<Rigidbody2D>();
    }

    private void Update()
    {
        if (Mathf.Abs(MoveInput) < 0.01f)
        {
            MoveInput = Input.GetAxisRaw("Horizontal");
        }

        if (!JumpPressed)
        {
            JumpPressed = Input.GetButtonDown("Jump");
        }

        _isGrounded = Physics2D.OverlapCircle(groundCheck.position, groundCheckRadius, groundLayer);

        if (JumpPressed && _isGrounded)
        {
            _rb.velocity = new Vector2(_rb.velocity.x, jumpForce);
        }

        if (MoveInput > 0f && !_facingRight)
        {
            Flip();
        }
        else if (MoveInput < 0f && _facingRight)
        {
            Flip();
        }

        JumpPressed = false;
    }

    private void FixedUpdate()
    {
        _rb.velocity = new Vector2(MoveInput * moveSpeed, _rb.velocity.y);
        MoveInput = 0f;
    }

    private void Flip()
    {
        _facingRight = !_facingRight;
        Vector3 scale = transform.localScale;
        scale.x *= -1f;
        transform.localScale = scale;
    }
}

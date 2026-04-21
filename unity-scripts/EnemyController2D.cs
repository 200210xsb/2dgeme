using UnityEngine;

public class EnemyController2D : MonoBehaviour
{
    public Transform leftPoint;
    public Transform rightPoint;
    public float moveSpeed = 2f;
    public float chaseRange = 6f;
    public float attackRange = 1.2f;
    public float attackCooldown = 1f;
    public int attackDamage = 1;
    public LayerMask playerLayer;

    private Transform _target;
    private float _lastAttackTime;
    private bool _movingRight = true;

    private void Start()
    {
        GameObject player = GameObject.FindGameObjectWithTag("Player");
        if (player != null)
        {
            _target = player.transform;
        }
    }

    private void Update()
    {
        if (_target == null)
        {
            Patrol();
            return;
        }

        float dist = Vector2.Distance(transform.position, _target.position);

        if (dist <= attackRange)
        {
            TryAttack();
        }
        else if (dist <= chaseRange)
        {
            Chase();
        }
        else
        {
            Patrol();
        }
    }

    private void Patrol()
    {
        Transform targetPoint = _movingRight ? rightPoint : leftPoint;
        transform.position = Vector2.MoveTowards(transform.position, targetPoint.position, moveSpeed * Time.deltaTime);

        if (Vector2.Distance(transform.position, targetPoint.position) < 0.05f)
        {
            _movingRight = !_movingRight;
            Flip();
        }
    }

    private void Chase()
    {
        transform.position = Vector2.MoveTowards(transform.position, _target.position, moveSpeed * Time.deltaTime);

        bool faceRight = _target.position.x > transform.position.x;
        Vector3 scale = transform.localScale;
        scale.x = Mathf.Abs(scale.x) * (faceRight ? 1f : -1f);
        transform.localScale = scale;
    }

    private void TryAttack()
    {
        if (Time.time - _lastAttackTime < attackCooldown)
        {
            return;
        }

        _lastAttackTime = Time.time;
        Collider2D hit = Physics2D.OverlapCircle(transform.position, attackRange, playerLayer);
        if (hit != null)
        {
            Health hp = hit.GetComponent<Health>();
            if (hp != null)
            {
                hp.TakeDamage(attackDamage);
            }
        }
    }

    private void Flip()
    {
        Vector3 scale = transform.localScale;
        scale.x *= -1f;
        transform.localScale = scale;
    }
}

using UnityEngine;

public class PlayerCombat : MonoBehaviour
{
    public Transform attackPoint;
    public float attackRadius = 0.8f;
    public LayerMask enemyLayer;
    public int baseDamage = 1;
    public float comboResetTime = 0.45f;

    public bool AttackPressed { get; set; }

    private float _lastAttackTime;
    private int _comboStep;

    private void Update()
    {
        if (!AttackPressed)
        {
            AttackPressed = Input.GetKeyDown(KeyCode.J);
        }

        if (Time.time - _lastAttackTime > comboResetTime)
        {
            _comboStep = 0;
        }

        if (AttackPressed)
        {
            Attack();
        }

        AttackPressed = false;
    }

    private void Attack()
    {
        _lastAttackTime = Time.time;
        _comboStep = Mathf.Clamp(_comboStep + 1, 1, 3);

        int damage = baseDamage + (_comboStep - 1);
        Collider2D[] hits = Physics2D.OverlapCircleAll(attackPoint.position, attackRadius, enemyLayer);

        for (int i = 0; i < hits.Length; i++)
        {
            Health hp = hits[i].GetComponent<Health>();
            if (hp != null)
            {
                hp.TakeDamage(damage);
            }
        }
    }
}

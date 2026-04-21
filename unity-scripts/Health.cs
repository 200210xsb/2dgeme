using UnityEngine;
using UnityEngine.Events;

public class Health : MonoBehaviour
{
    public int maxHp = 5;
    public UnityEvent onDeath;

    private int _currentHp;
    private bool _dead;

    private void Awake()
    {
        _currentHp = maxHp;
    }

    public void TakeDamage(int amount)
    {
        if (_dead || amount <= 0)
        {
            return;
        }

        _currentHp -= amount;
        if (_currentHp <= 0)
        {
            Die();
        }
    }

    private void Die()
    {
        if (_dead)
        {
            return;
        }

        _dead = true;
        onDeath?.Invoke();
        Destroy(gameObject);
    }
}

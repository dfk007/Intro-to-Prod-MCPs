import pytest
from main import calculate_fibonacci

def test_fibonacci_base_cases():
    assert calculate_fibonacci(0) == 0
    assert calculate_fibonacci(1) == 1

def test_fibonacci_recursive():
    assert calculate_fibonacci(5) == 5
    assert calculate_fibonacci(10) == 55

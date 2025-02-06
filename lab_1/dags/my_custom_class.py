# my_custom_class.py

class MyCustomClass:
    def __init__(self, name):
        self.name = name

    def greet(self):
        print(f">>> (MyCustomClass) Hello, {self.name}! Welcome to the Airflow DAG.")


def my_func(x, y):
    return x+y
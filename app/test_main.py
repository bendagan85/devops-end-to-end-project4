import pytest
from main import app


@pytest.fixture
def client():
    with app.test_client() as client:
        yield client


def test_hello_route(client):
    rv = client.get('/')
    # תיקון: במקום לבדוק שוויון מלא, נבדוק שהתשובה מכילה את הברכה
    # זה מאפשר ל-Hostname להשתנות בלי לשבור את הטסט
    assert "Hello, DevOps!" in rv.data.decode()


def test_echo_route(client):
    test_data = {"message": "test"}
    rv = client.post('/echo', json=test_data)
    assert rv.get_json() == test_data
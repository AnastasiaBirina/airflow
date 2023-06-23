import logging

import pendulum
from examples.dds import DDSEtlSettingsRepository
from airflow.decorators import dag, task
from examples.dds.dds_dag.users_loader import UserLoader

from lib import ConnectionBuilder

log = logging.getLogger(__name__)


@dag(
    schedule_interval='0/15 * * * *',  # Задаем расписание выполнения дага - каждый 15 минут.
    start_date=pendulum.datetime(2023, 6, 22, tz="UTC"),  # Дата начала выполнения дага. Можно поставить сегодня.
    catchup=False,  # Нужно ли запускать даг за предыдущие периоды (с start_date до сегодня) - False (не нужно).
    tags=['sprint5', 'dds', 'origin', 'example'],  # Теги, используются для фильтрации в интерфейсе Airflow.
    is_paused_upon_creation=True  # Остановлен/запущен при появлении. Сразу запущен.
)
def dds_load_dag():
    # Создаем подключение к базе dwh.
    dwh_pg_connect = ConnectionBuilder.pg_conn("PG_WAREHOUSE_CONNECTION")

    # Объявляем таск, который загружает данные.
    @task(task_id="load_users")
    def load_users():
        # создаем экземпляр класса, в котором реализована логика.
        rest_loader = UserLoader(dwh_pg_connect, DDSEtlSettingsRepository())
        rest_loader.load_users()  # Вызываем функцию, которая перельет данные.

    # Инициализируем объявленные таски.
    users_load = load_users()

    # Далее задаем последовательность выполнения тасков.
    # Т.к. таск один, просто обозначим его здесь.
    users_load


dds_dag = dds_load_dag()

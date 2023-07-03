import logging

import pendulum
from examples.dds import DDSEtlSettingsRepository
from airflow.decorators import dag, task
from examples.dds.dds_dag.fct_products_loader import FctProductsLoader
from examples.dds.dds_dag.users_loader import UserLoader
from examples.dds.dds_dag.rest_loader import RestLoader
from examples.dds.dds_dag.ts_loader import TimestampLoader
from examples.dds.dds_dag.products_loader import ProductLoader
from examples.dds.dds_dag.orders_loader import OrderLoader
from examples.dds.dds_dag.cdm_load import CDMLoader
from airflow.utils.task_group import TaskGroup
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

    # Объявляем таск, который загружает данные о пользователях
    @task(task_id="load_users")
    def load_users():
        # создаем экземпляр класса, в котором реализована логика.
        user_loader = UserLoader(dwh_pg_connect, DDSEtlSettingsRepository())
        user_loader.load_users()  # Вызываем функцию, которая перельет данные.

    # Объявляем таск, который загружает данные о ресторанах
    @task(task_id="load_rest")
    def load_rest():
        # создаем экземпляр класса, в котором реализована логика.
        rest_loader = RestLoader(dwh_pg_connect, DDSEtlSettingsRepository())
        rest_loader.load_rest()  # Вызываем функцию, которая перельет данные.

    # Объявляем таск, который загружает данные timestamp
    @task(task_id="load_ts")
    def load_ts():
        # создаем экземпляр класса, в котором реализована логика.
        ts_loader = TimestampLoader(dwh_pg_connect, DDSEtlSettingsRepository())
        ts_loader.load_timestamps()  # Вызываем функцию, которая перельет данные.

    # Объявляем таск, который загружает данные timestamp
    @task(task_id="load_products")
    def load_products():
        # создаем экземпляр класса, в котором реализована логика.
        products_loader = ProductLoader(dwh_pg_connect, DDSEtlSettingsRepository(), log)
        products_loader.load_products()  # Вызываем функцию, которая перельет данные.

    @task(task_id="load_orders")
    def load_orders():
        # создаем экземпляр класса, в котором реализована логика.
        orders_loader = OrderLoader(dwh_pg_connect, DDSEtlSettingsRepository(), log)
        orders_loader.load_orders()  # Вызываем функцию, которая перельет данные.

    @task(task_id="load_fcts")
    def load_fcts():
        # создаем экземпляр класса, в котором реализована логика.
        fcts_loader = FctProductsLoader(dwh_pg_connect, DDSEtlSettingsRepository())
        fcts_loader.load_product_facts()  # Вызываем функцию, которая перельет данные.

    @task(task_id="load_cdm")
    def load_cdm():
        # создаем экземпляр класса, в котором реализована логика.
        cdm_loader = CDMLoader(dwh_pg_connect)
        cdm_loader.load_cdm()  # Вызываем функцию, которая перельет данные.



    # Инициализируем объявленные таски.
    users_load = load_users()
    rest_load = load_rest()
    ts_load = load_ts()
    products_load = load_products()
    orders_load = load_orders()
    fcts_load = load_fcts()
    cdm_load = load_cdm()


    

    # Далее задаем последовательность выполнения тасков.
    # Т.к. таск один, просто обозначим его здесь.
    [users_load, rest_load, ts_load] >> products_load >> orders_load >> fcts_load >> cdm_load


dds_dag = dds_load_dag()

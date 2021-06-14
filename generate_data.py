# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
import contextlib
import datetime
import random
from collections import defaultdict

import pandas as pd
from faker import Faker
from sqlalchemy import create_engine, insert, MetaData, Table, text, func, select, Column, Integer


def print_hi(name):
    # Use a breakpoint in the code line below to debug your script.
    print(f'Hi, {name}')  # Press Ctrl+F8 to toggle the breakpoint.


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    print_hi('PyCharm')

fake = Faker('pl_PL')
# fake = Faker()

fake_data = defaultdict(list)

for _ in range(100):
    fake_data["first_name"].append(fake.first_name())
    fake_data["last_name"].append(fake.last_name())
    fake_data["occupation"].append(fake.job())
    fake_data["dob"].append(fake.date_of_birth())
    fake_data["country"].append(fake.country())

df_fake_data = pd.DataFrame(fake_data)

df_fake_data

engine = create_engine('mssql+pyodbc://sa:KuBaWaL1@localhost/master?driver=ODBC+Driver+17+for+SQL+Server',
                       pool_pre_ping=True)
# definicja tabel
meta = MetaData(bind=engine)

client = Table('client', meta, autoload_with=engine)
bookable_table = Table('bookable_table', meta, autoload_with=engine)
item = Table('item', meta, Column('id', Integer, primary_key=True), autoload_with=engine)
employee = Table('employee', meta, autoload_with=engine)
menu = Table('menu', meta, autoload_with=engine)
menu_position = Table('menu_position', meta, autoload_with=engine)
order = Table('order', meta, autoload_with=engine)
order_position = Table('order_position', meta, autoload_with=engine)

# Przydatne stałe:
ilosc_klientow = 10
number_of_tables = 20
number_of_items = 20
number_of_emplyees = 10
# number_of_menu = 10
old_order_number = 100  # Ilość zamówień już zrobionych z poprzednich dni
items_per_order = 5

mnim = maks_number_items_menu = 10
mnop = maks_number_order_position = 30


def make_data_client(ilosc_klientow):
    with engine.connect() as conn:
        for client_id in range(ilosc_klientow):  # loop private clients
            result = conn.execute(insert(client).values(id=client_id,
                                                        name=fake.name(),
                                                        client_type='Private',
                                                        email=fake.email()
                                                        )
                                  )
        for client_id in range(ilosc_klientow, 2 * ilosc_klientow):
            result = conn.execute(insert(client).values(id=client_id,  # loop company clients
                                                        name=fake.bs(),
                                                        client_type='Company',
                                                        email=fake.email(),
                                                        phone_number=str(random.randrange(100000000, 999999999)),
                                                        nip=str(random.randrange(100000000, 999999999)),
                                                        company_address_street=fake.street_name(),
                                                        company_address_house_number=str(fake.building_number()),
                                                        company_address_flat_number=str(fake.building_number()),
                                                        company_address_zip_code=(
                                                                str(random.randrange(10, 99)) + "-" + str(
                                                            random.randrange(100, 999))),
                                                        company_address_city=fake.city()
                                                        )
                                  )


def make_data_bookable_table(number_of_tables):
    with engine.connect() as conn:
        for table_number in range(number_of_tables):  # loop tables
            result = conn.execute(insert(bookable_table).values(id=table_number,
                                                                seats_count=(random.randrange(2, 9, 2))
                                                                )
                                  )


def make_data_item(number_of_items):
    with engine.connect() as conn:
        for item_number in range(number_of_items):  # loop items
            result = conn.execute(insert(item).values(id=item_number,
                                                      is_seafood=(random.choice([0, 1])),
                                                      price_netto=(random.randrange(100, 20000, 10) / 100),
                                                      tax_rate=random.choice([0.07, 0.23]),
                                                      name=fake.text(max_nb_chars=255)
                                                      )
                                  )


def make_data_employee(number_of_emplyees):
    with engine.connect() as conn:
        for employee_number in range(number_of_emplyees):  # loop items
            result = conn.execute(insert(employee).values(id=employee_number,
                                                          name=fake.name()
                                                          )
                                  )


def make_data_menu():
    with engine.connect() as conn:
        menu_number = 0
        menu_start_date = datetime.datetime.combine(
            fake.date_between(start_date=datetime.date.today(), end_date='+10d'),
            datetime.datetime.min.time())
        while (menu_start_date > (datetime.datetime.combine(
                (datetime.date.today() - datetime.timedelta(days=300)), datetime.datetime.min.time()))):
            menu_end_date = datetime.datetime.combine(menu_start_date - datetime.timedelta(days=1),
                                                      datetime.datetime.min.time())
            menu_start_date = datetime.datetime.combine(menu_end_date -
                                                        datetime.timedelta(days=random.randrange(1, 14)),
                                                        datetime.datetime.min.time())
            menu_creat_date = datetime.datetime.combine(menu_start_date -
                                                        datetime.timedelta(days=random.randrange(1, 14)),
                                                        datetime.datetime.min.time())

            result = conn.execute(insert(menu).values(id=menu_number,
                                                      start_date=menu_start_date,
                                                      end_date=menu_end_date,
                                                      created_date=menu_creat_date,
                                                      created_by_employee_id=random.randrange(number_of_emplyees)
                                                      )
                                  )
            menu_number += 1
        return menu_number


# Bardzo brzydkie przerabianie date na datetime, ale nie ma czasu.

# Więc tak: Dla każdego menu robimy losową ilość itemów z zakresu numer_tems_menu i polowa tego.
def make_data_menu_position():
    with engine.connect() as conn:
        for menu_number in range(1, number_of_menu):
            for menu_item_number in random.sample(range(0, number_of_items),
                                                  random.randrange(mnim / 2, mnim)):
                result = conn.execute(insert(menu_position).values(item_id=menu_item_number,
                                                                   menu_id=menu_number
                                                                   )
                                      )
        # menu_id=0, full menu
        for item_id in range(number_of_items):
            conn.execute(insert(menu_position).values(item_id=item_id, menu_id=0))


def make_data_order(old_order_number):
    with engine.connect() as conn:
        for order_number in range(old_order_number):  # loop order
            client_id_data = None
            is_takeaway_data = None
            channel_data = 'Local'
            min_ready_time_data = None
            predicted_ready_time_data = None
            if random.choice([True, False]):
                client_id_data = random.randrange(ilosc_klientow * 2)

            if random.choice([True, False]):
                is_takeaway_data = True
                if random.choice([True, False]):
                    channel_data = 'Web'
                    min_ready_time_data = fake.date_time_between(start_date='-300d', end_date='now')
                    predicted_ready_time_data = min_ready_time_data + datetime.timedelta(
                        minutes=random.randrange(0, 10))
            else:
                is_takeaway_data = False

            result = conn.execute(insert(order).values(id=order_number,
                                                       client_id=client_id_data,
                                                       is_takeaway=is_takeaway_data,
                                                       channel=channel_data,
                                                       min_ready_time=min_ready_time_data,
                                                       predicted_ready_time=predicted_ready_time_data,
                                                       status='Ready',
                                                       created_time=datetime.datetime.combine(fake.date_object(),
                                                                                              datetime.datetime.min.time())
                                                       )
                                  )


def make_data_order_position():
    with engine.connect() as conn:
        for order_id in range(old_order_number):
            for item_id in random.sample(range(number_of_items), 5):
                item_data = conn.execute(select([item]).where(item.c.id == item_id)).fetchone()
                conn.execute(
                    insert(order_position).values(
                        order_id=order_id,
                        item_id=item_id,
                        menu_id=0,
                        saved_price_netto=item_data.price_netto,
                        saved_tax_rate=item_data.tax_rate,
                        quantity=random.choice(range(5))
                    )
                )


def clear_table():
    with contextlib.closing(engine.connect()) as con:
        trans = con.begin()
        for table in reversed(meta.sorted_tables):
            con.execute(table.delete())
        trans.commit()


clear_table()
make_data_client(ilosc_klientow)
make_data_bookable_table(number_of_tables)
make_data_item(number_of_items)
make_data_employee(number_of_emplyees)
number_of_menu = make_data_menu()
make_data_menu_position()
make_data_order(old_order_number)
make_data_order_position()
# result = conn.execute(ins)

# print("%s" % (.columns.keys))

# See PyCharm help at https://www.jetbrains.com/help/pycharm/

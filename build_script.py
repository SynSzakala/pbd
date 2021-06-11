import os
from io import open

objects_files = [
    'tables/drop_tables',
    'routines/drop_routines',
    'tables/create_tables',
    'routines/util',
    'routines/client',
    'routines/discount_common',
    'routines/discount_R1',
    'routines/discount_R2',
    'routines/discount_both',
    'tables/create_tables_late',
    'routines/discount_R2_trigger',
    'routines/menu',
    'routines/table',
    'routines/order_common',
    'routines/order_local',
    'routines/order_web',
]

views_files = os.listdir('views')

files = \
    [file + '.sql' for file in objects_files] + \
    ['views/' + file for file in views_files]

with open('generated.sql', 'w') as output:
    for file in files:
        output.write('\n\n-- ' + file + ' --\n\n')
        with open(file, 'r') as input:
            for line in input:
                output.write(line)
        output.write('\ngo;\n')

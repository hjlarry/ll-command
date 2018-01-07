import os
import click
from datetime import datetime
import unicodedata
from terminaltables import AsciiTable


TABLE_WIDTH = 30
NO_DESCRIPTION = ''
CAN_NOT_GET = ''


def get_file_comments(file):
    with open(file, 'r') as f:
        content = f.readline()
        if len(content.strip()) > 3 and (content.strip().endswith("'''") or content.endswith('"""')): #  注释在一行时
            return content[3:-4].strip()
        elif content.startswith('#'): #  以#号注释时
            return content[1:].strip()
        elif content.startswith("'''") or content.startswith('"""'): #  注释在多行时
            content = f.readline()
            return content.strip()
        else:
            return NO_DESCRIPTION


def get_file_lines(file):
    try:
        with open(file, 'r') as f:
            return len(f.readlines())
    except:
        return 0


def get_dir_lines(dir, depth=0):
    # lines = 0
    # if os.path.isdir(dir) and depth < 3:
    #     for d in os.listdir(dir):
    #         if os.path.isfile(dir+'/'+d):
    #             lines += get_file_lines(dir+'/'+d)
    #         else:
    #             current_line = get_dir_lines(dir+'/'+d, depth+1)
    #             lines += current_line if isinstance(current_line, int) else 0
    # return lines if depth<3 else '>'+str(lines)
    return CAN_NOT_GET


def lines_and_description(dir):
    if os.path.isfile(dir):
        return get_file_lines(dir), get_file_comments(dir)
    elif os.path.isdir(dir):
        path = dir + '/__init__.py'
        comments = get_file_comments(path) if os.path.exists(path) else NO_DESCRIPTION
        return get_dir_lines(dir), comments
    else:
        raise Exception


def wide_chars(s):
    # 使中英文字符在控制台所占宽度相同
    res = 0
    for c in s:
        if (unicodedata.east_asian_width(c) in ('F', 'W', 'A')):
            res += 2
        else:
            res += 1
    return res


def main():
    dirs = os.listdir()
    click.secho('Current Path:{}'.format(os.getcwd())+ '    File Count:{}'.format(len(dirs)), fg='red')
    table_data = [['filename', 'last modify time', 'lines', 'description']]
    for dir in dirs:
        dirname = dir[:20]+'...' if len(dir)>20 else dir
        try:
            last_modify_time = str(datetime.fromtimestamp(os.path.getmtime(dir)))[:19]
        except:
            last_modify_time = CAN_NOT_GET
        try:
            lines, description = lines_and_description(dir)
            description = description[:37]+'...' if len(description)>40 else description
        except:
            lines, description = CAN_NOT_GET, NO_DESCRIPTION
        table_data.append([dirname, last_modify_time, lines, description])
        # color = 'cyan' if os.path.isfile(dir) else 'magenta'
        # click.secho(dirname +' ' * (TABLE_WIDTH - wide_chars(dirname)) +last_modify_time+ ' '*10 + '{0: ^10}'.format(lines)+'{0: ^40}'.format(description), fg=color)
    table = AsciiTable(table_data)
    print(table.table)

if __name__ == '__main__':
    main()
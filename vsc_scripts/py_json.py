#!/usr/bin/env python3
import sys
import os
import json

# debug = True
debug = False
# find .  -name .git -type d | sed 's|/.git$||' | xargs -I{} add_json_value_to .vscode/settings.json "git.ignoredRepositories" {}

def dbg_print(msg):
    if debug:
        print(f"[DEBUG] {msg}")

def create_empty_json_array(js_file, js_key):
    f = None
    data = {}
    
    # 文件不存在则创建
    if not os.path.isfile(js_file):
        # 先创建目录（类似 mkdir -p）
        dir_path = os.path.dirname(js_file)
        if dir_path:
            os.makedirs(dir_path, exist_ok=True)
        # 创建文件
        f = open(js_file, 'w').close()
        f = open(js_file, 'r+')
    else:
        try:
            f = open(js_file, 'r+')
            data = json.load(f)
        except json.JSONDecodeError:
            print(f"错误: 文件 {js_file} 不是有效的 JSON 文件")
            sys.exit(1)

    f.seek(0)
    f.truncate()
    
    data[js_key] = []

    json.dump(data, f, indent=4)
    f.close()

def add_json_value_to_array():
    if len(sys.argv) < 4:
        print("用法: add_json_value_to <json_file> <json_key> <json_value>")
        sys.exit(1)
    js_file = sys.argv[1]
    js_key = sys.argv[2]
    js_value = sys.argv[3]
    dbg_print(f"添加值到数组: 文件={js_file}, 键={js_key}, 值={js_value}")
    # 检测文件是否存在
    if not os.path.isfile(js_file):
        create_empty_json_array(js_file, js_key)

    try:
        with open(js_file, 'r') as f:
            data = json.load(f)
    except json.JSONDecodeError:
        print(f"错误: 文件 {js_file} 不是有效的 JSON 文件")
        sys.exit(1)

    if js_key not in data:
        create_empty_json_array(js_file, js_key)

    f = open(js_file, 'r+')
    data = json.load(f)
    if type(data[js_key]) is list:
        if js_value not in data[js_key]:
            data[js_key].append(js_value)
            with open(js_file, 'w') as f:
                f.seek(0)
                f.truncate()
                json.dump(data, f, indent=4)
                f.close()
    else:
        print(f"错误: 键 {js_key} 不是一个数组")
        sys.exit(1)

    # f = None
    # try:
    #     f = open(js_file, 'r+')
    #     data = json.load(f)
    # except json.JSONDecodeError:
    #     print(f"错误: 文件 {js_file} 不是有效的 JSON 文件")
    #     sys.exit(1)
    # f.seek(0)
    # f.truncate()

    # # if js_key in data:
    
    # else:
    #     set_json_value_to(js_file, js_key, js_value)
        


def set_json_value_to():
    if len(sys.argv) < 4:
        print("用法: set_json_value_to <json_file> <json_key> <json_value>")
        sys.exit(1)
    js_file = sys.argv[1]
    js_key = sys.argv[2]
    js_value = sys.argv[3]

    f = None
    data = {}
    
    # 文件不存在则创建
    if not os.path.isfile(js_file):
        # 创建
        f = open(js_file, 'w').close()
        f = open(js_file, 'r+')
    else:
        try:
            f = open(js_file, 'r+')
            data = json.load(f)
        except json.JSONDecodeError:
            print(f"错误: 文件 {js_file} 不是有效的 JSON 文件")
            sys.exit(1)

    f.seek(0)
    f.truncate()
    
    data[js_key] = js_value

    json.dump(data, f, indent=4)
    f.close()
def get_json_value_from():
    if len(sys.argv) < 3:
        print("用法: get_json_value_from <json_file> <json_key>")
        sys.exit(1)
    js_file = sys.argv[1]
    js_key = sys.argv[2]

    # 检测文件是否存在
    if not os.path.isfile(js_file):
        print(f"错误: 文件 {js_file} 不存在")
        sys.exit(1)

    try:
        with open(js_file, 'r') as f:
            data = json.load(f)
    except json.JSONDecodeError:
        print(f"错误: 文件 {js_file} 不是有效的 JSON 文件")
        sys.exit(1)

    try:
        result = data[js_key]
    except KeyError:
        print(f"错误: 键 {js_key} 不存在于 JSON 文件中")
        sys.exit(1)

    print(result)


if __name__ == "__main__":
    # 获取程序名称（不含路径）
    prog_name = os.path.basename(sys.argv[0]).replace('.py', '')
    
    if prog_name == "get_json_value_from":
        dbg_print(f"参数: {sys.argv[1:]}")
        get_json_value_from()
    elif prog_name == "set_json_value_to":
        dbg_print(f"参数: {sys.argv[1:]}")
        set_json_value_to()
    elif prog_name == "add_json_value_to_array":
        dbg_print(f"参数: {sys.argv[1:]}")
        add_json_value_to_array()
    else:
        # 创建软链接
        os.symlink(sys.argv[0], "get_json_value_from")
        os.symlink(sys.argv[0], "set_json_value_to")
        os.symlink(sys.argv[0], "add_json_value_to_array")
        # 默认: 命令行参数指定函数
        if len(sys.argv) < 2:
            print("用法: py_json <function> [args...]")
            sys.exit(1)
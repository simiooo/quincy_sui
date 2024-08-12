import os
import re

def find_strings_in_dart_files(directory, regex):
    """
    在指定目录下查找所有以.dart结尾的文件中匹配指定正则表达式的字符串，并返回匹配结果、文件名和行数。

    :param directory: 要搜索的目录的绝对路径
    :param regex: 用于匹配的正则表达式
    :return: 一个列表，包含匹配到的字符串、对应的文件名和行数
    """
    results = []
    # 编译正则表达式
    compiled_regex = re.compile(regex)

    # 遍历目录下的所有文件
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as f:
                    for line_number, line in enumerate(f, start=1):
                        # 使用正则表达式匹配
                        matches = compiled_regex.findall(line)
                        for match in matches:
                            results.append((match, file_path, line_number))

    return results

# 示例用法

directory = 'D:\quincy_sui\lib'
regex = r'Text\(.+\)'

matches = find_strings_in_dart_files(directory, regex)
for match, file_path, line_number in matches:
    print(f"Found '{match}' in file '{file_path}' at line {line_number}")
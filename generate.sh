#!/bin/bash

# 检查参数数量
print_help() {
  echo "Usage: ./generate.sh <executable_file_name> <param1=value1> <param2=value2> ... <paramN=valueN>"
  echo "Example: ./generate.sh foo -bind=10.0.0.2 -server=1.1.1.1:1234"
  echo ""
  echo "This script generates two scripts:"
  echo "1. start.sh - Starts the provided executable in the background with the provided parameters."
  echo "   Output is redirected to a log file named <executable>_output.log."
  echo "2. stop.sh  - Stops the running process of the executable using its PID."
  echo ""
  echo "Options:"
  echo "  -h, --help, ?  Show this help message and exit."
}

# 检查是否请求帮助
if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "?" ]]; then
  print_help
  exit 0
fi

# 检查参数数量
if [ "$#" -lt 1 ]; then
  echo "Error: Missing executable."
  print_help
  exit 1
fi
# 可执行文件名
executable=$1

# 获取所有参数（从第二个参数开始），并将它们保存到参数字符串中
shift
params="$@"

# 创建 start.sh
cat <<EOL > start.sh
#!/bin/bash
# 启动 $executable，传入的参数为: $params
nohup ./$executable $params > ${executable}_output.log 2>&1 &
echo "\$!" > ${executable}.pid
echo "$executable started and running in the background."
EOL

# 使 start.sh 可执行
chmod +x start.sh

# 创建 stop.sh
cat <<EOL > stop.sh
#!/bin/bash
# 停止 $executable
if [ -f "${executable}.pid" ]; then
  pid=\$(cat ${executable}.pid)
  if kill -0 "\$pid" 2>/dev/null; then
    kill "\$pid"
    echo "$executable (PID: \$pid) stopped."
    rm ${executable}.pid
  else
    echo "Process not running or already stopped."
  fi
else
  echo "No PID file found. Is $executable running?"
fi
EOL

# 使 stop.sh 可执行
chmod +x stop.sh

echo "Scripts start.sh and stop.sh generated successfully."

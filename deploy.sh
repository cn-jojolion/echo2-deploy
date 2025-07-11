#!/bin/bash

# 检查并安装命令的函数
check_and_install() {
    local command_name="$1"
    local install_command="$2"

    # 使用 type -p 检测可执行文件，type 检测函数/别名
    if type -p "$command_name" >/dev/null 2>&1 || type "$command_name" >/dev/null 2>&1; then
        echo "✅ $command_name 已安装"
        return 0
    else
        echo "⚠️  命令 $command_name 未安装，尝试安装..."
        
        # 执行安装命令
        if eval "$install_command"; then
            # 再次验证是否安装成功
            if type -p "$command_name" >/dev/null || type "$command_name" >/dev/null 2>&1; then
                echo "✅ 成功安装 $command_name"
                return 0
            else
                echo "❌ 安装失败：$command_name 仍未找到"
                return 1
            fi
        else
            echo "❌ 安装命令执行失败: $install_command"
            return 1
        fi
    fi

    
    # 检查命令是否存在
    if (command -v "$command_name" &> /dev/null;) then
        echo "✅ 命令 $command_name 已安装"
        return 0
    else
        echo "⚠️  命令 $command_name 未安装，尝试安装..."
        
        # 执行安装命令
        if eval "$install_command"; then
            # 再次验证是否安装成功
            if command -v "$command_name" &>/dev/null; then
                echo "✅ 成功安装 $command_name"
                return 0
            else
                echo "❌ 安装失败：$command_name 仍未找到"
                return 1
            fi
        else
            echo "❌ 安装命令执行失败: $install_command"
            return 1
        fi
    fi
}

#######################################################################################
# 替换变量函数
# 参数1: YAML配置文件路径
# 参数2: 模板文件路径
# 参数3: 输出文件路径（可选，默认为模板文件同目录下的output.txt）
replace_variables() {
    local CONFIG_CONTENT="$1"    # YAML 配置内容（字符串）
    local TEMPLATE_CONTENT="$2"  # 模板内容（字符串）
    local OUTPUT_FILE="${3:-output.txt}"  # 输出文件（可选，默认 output.txt）

    # 检查参数是否为空
    if [ -z "$CONFIG_CONTENT" ]; then
        echo "错误: 配置内容不能为空"
        return 1
    fi

    if [ -z "$TEMPLATE_CONTENT" ]; then
        echo "错误: 模板内容不能为空"
        return 1
    fi

    local template_content="$TEMPLATE_CONTENT"
    
    # 获取所有需要替换的变量
    variables=$(grep -oP '{\$\K[^}]+' <<< "$template_content" || true)
    
    for var in $variables; do
        # 从 YAML 内容中提取变量值（使用 yq 解析字符串）
        value=$(echo "$CONFIG_CONTENT" | yq eval ".${var}" -)
        
        # 替换模板中的变量（兼容 ${VAR} 和 {$VAR} 格式）
        template_content=${template_content//"\${$var}"/$value}
        template_content=${template_content//"{\$$var}"/$value}
    done
    
    # 输出结果
    echo "$template_content" > "$OUTPUT_FILE"
    echo "✅ 变量替换完成，结果已保存到 $OUTPUT_FILE"
}
#######################################################################################

# 使用示例：检查并安装 git
check_and_install "git" "sudo apt-get update && sudo apt-get install -y git"

# 检查并安装 nvm
check_and_install "nvm" "
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && 
export NVM_DIR=\"\$HOME/.nvm\" && 
[ -s \"\$NVM_DIR/nvm.sh\" ] && 
\\. \"\$NVM_DIR/nvm.sh\" && 
nvm install 18 && 
nvm install 20
"

#检查 pnpm 
check_and_install "pnpm" "npm install pnpm -g"


#检查 gettext
#check_and_install "pnpm" "npm install pnpm -g"
 
#检查 gettext
check_and_install "yq" "apt install yq"

export ABC=123
export ABC="http://client-api.bitsfort.com"
env
cd /home
rm -rf /home/echo-client-h5
git clone https://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@github.com/cn-jojolion/echo-client-h5.git
cd ./echo-client-h5
replace_variables "$(curl -sfSL https://raw.githubusercontent.com/cn-jojolion/echo2-deploy/refs/heads/main/.depoly/deply-bitsfort.yml)" "$(cat /home/echo-client-h5/.env.production)"

# nvm use 20
# pnpm install
# pnpm run build


# 给定一个tags列表，检查是否包含某个指定的tag
{ tags, tagToCheck }: builtins.elem tagToCheck tags

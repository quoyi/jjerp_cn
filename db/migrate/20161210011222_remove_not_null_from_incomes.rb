class RemoveNotNullFromIncomes < ActiveRecord::Migration[6.0]
  # 修改收入incomes 的 indent_id 、order_id 可以为空
  def change
  	remove_reference :incomes, :indent
  	remove_reference :incomes, :order
  	add_reference :incomes, :indent, null: true
  	add_reference :incomes, :order, null: true
  end
end

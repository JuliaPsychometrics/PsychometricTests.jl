abstract type Item end

getid(item::Item) = item.id

struct BasicItem{I} <: Item
    id::I
end

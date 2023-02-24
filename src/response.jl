abstract type Response end

getvalue(response::Response) = response.value
getitemid(response::Response) = response.item_id
getpersonid(response::Response) = response.person_id

struct BasicResponse{IIT,PIT,T} <: Response
    item_id::IIT
    person_id::PIT
    value::T
end


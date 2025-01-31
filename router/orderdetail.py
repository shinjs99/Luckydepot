from database.model.orderdetail import OrderDetail
from database.model.product import Product
from database.model.order import Order
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import desc, func, cast, String
from database.conn.connection import db
from datetime import datetime, timedelta



router = APIRouter()
# 관리자용 매출 연별 조회
@router.get('/year', status_code=200)
async def select(session : Session = Depends(db.session)):
    """
    관리자용
    상품이름, 상품별 판매수량, 상품별 총 합 조회
    """
    try :
        # 현재 시간 기준 년도
        current_year = datetime.now().strftime('%y')
        orders = session.query(
            Product.name, # 상품 이름
            func.sum(OrderDetail.quantity).label('order_count'), # 판매 수량
            func.sum(OrderDetail.price).label('total_price'), # 총 합
        ).join(
            Product, 
            Product.id == OrderDetail.product_id
        ).filter(
            cast(func.substring(OrderDetail.id, 1, 2), String) == current_year
        ).group_by(
        Product.name
        ).order_by(desc('order_count'))
        if not orders :
            raise HTTPException(status_code=400, detail="detail year not found")
        return {'result' : 
                    [
                        {
                            'name' : order[0],
                            'order_count' : order[1],
                            'total_price' : order[2]
                        }
                        for order in orders
                    ]
                }
    except Exception as e:
        return {'result' : e}

# 관리자용 매출 관리 주별 조회
@router.get('/week')
async def select(session : Session = Depends(db.session)):
    """
    관리자용 매출관리 "월"
    상품이름, 상품별 판매수량, 상품별 총 합 조회
    """
    try :
        # 현재 날짜 기준으로 이번주의 시작일과 종료일 계산
        current_date = datetime.now()
        # 월요일이 0, 일요일이 6
        start_of_week = current_date - timedelta(days=current_date.weekday())
        end_of_week = start_of_week + timedelta(days=6)
        orders = session.query(
            Product.name, # 상품 이름
            func.sum(OrderDetail.quantity).label('order_count'), # 판매 수량
            func.sum(OrderDetail.price).label('total_price'), # 총 합
        ).join(
            Product, 
            Product.id == OrderDetail.product_id
        ).filter(
            cast(func.substring(OrderDetail.id, 1, 6), String).between(
                start_of_week.strftime('%y%m%d'),
                end_of_week.strftime('%y%m%d')
            )
        ).group_by(
        Product.name
        ).order_by(desc('order_count'))
        if not orders :
            raise HTTPException(status_code=400, detail="detail week not found")
        return {'result' : 
                    [
                        {
                            'name' : order[0],
                            'order_count' : order[1],
                            'total_price' : order[2]
                        }
                        for order in orders
                    ]
                }
    except Exception as e:
        return {'result' : e}


# 관리자용 매출 관리 주별 조회
@router.get('/month')
async def select(session : Session = Depends(db.session)):
    """
    관리자용 매출관리 "월"
    상품이름, 상품별 판매수량, 상품별 총 합 조회
    """
    try :
        # 현재 시간 기준 월
        current_month = datetime.now().strftime('%m')
        orders = session.query(
            Product.name, # 상품 이름
            func.sum(OrderDetail.quantity).label('order_count'), # 판매 수량
            func.sum(OrderDetail.price).label('total_price'), # 총 합
        ).join(
            Product, 
            Product.id == OrderDetail.product_id
        ).filter(
            cast(func.substring(OrderDetail.id, 3, 2), String) == current_month
        ).group_by(
        Product.name
        ).order_by(desc('order_count'))
        if not orders :
            raise HTTPException(status_code=400, detail="detail month not found")
        return {'result' : 
                    [
                        {
                            'name' : order[0],
                            'order_count' : order[1],
                            'total_price' : order[2]
                        }
                        for order in orders
                    ]
                }
    except Exception as e:
        return {'result' : e}


@router.get("/select/{user_seq}")
async def user(session : Session = Depends(db.session), user_seq : int = None):
    """
    사용자용
    user_seq(pk)를 통해 orderdetail 테이블 조회
    """
    try :
        orderdetail = session.query(
            OrderDetail.id,
            OrderDetail.user_seq,
            OrderDetail.product_id, 
            OrderDetail.price, 
            OrderDetail.quantity
            ).filter(OrderDetail.user_seq == user_seq).all()
        if not orderdetail :
            raise HTTPException(status_code=400, detail="detail user not found")
        return { "result": 
                [
                    {
                    "id" : detail[0],
                    "user_seq" : detail[1],
                    "prodcut_id": detail[2], # 상품 아이디(pk)
                    "price": detail[3], # 상품 가격
                    "quantity": detail[4], # 수량
                    }
                for detail in orderdetail
                ],
            }
    except Exception as e:
        return {'result' : e}




@router.get('/insert')
async def insert(session : Session = Depends(db.session), id : str = None, user_seq : int = None, product_id : int = None, price : float = None, quantity : int = None, name : str = None):
    """
    사용자용
    주문시 orderdetail 입력
    """
    try :
        new_order = OrderDetail(
            id = id,
            user_seq = user_seq,
            product_id = product_id,
            price = price,
            quantity = quantity,
            name = name
        )
        session.add(new_order)
        session.commit()
        return {'result' : 'ok'}
    except Exception as e:
        return {'result' : e}


@router.delete('/delete')
async def delete(session : Session = Depends(db.session), orderdetail_id : str = None):
    """
    필요시 사용
    orderdetail 정보 삭제 
    orderdetail_id (pk) 사용
    """
    try :
        orderdetail = session.query(OrderDetail).filter(OrderDetail.id == orderdetail_id).first()
        session.delete(orderdetail)
        session.commit()
        return {'result' : 'ok'}
    except Exception as e:
        return {'result' : e}


@router.get('/list/{user_seq}')
async def select_orderlist(session : Session = Depends(db.session), user_seq : int = None):
    """
    주문내역 불러오기
    대표상품 : name, quantity,image
    총 합 : price
    count : 주문 상품 갯수 -1 
    """
    try:
        lists = session.query(
            OrderDetail.id,
            func.min(Product.image).label('image'),
            func.min(Product.name).label('name'),
            func.count(OrderDetail.name).label('count'),
            func.min(OrderDetail.quantity).label('quantity'),
            func.sum(OrderDetail.price).label('price'),
            ).join(
                Product,
                Product.id == OrderDetail.product_id,
            ).filter(
                OrderDetail.user_seq  == user_seq,
            ).group_by(
                OrderDetail.id,
                OrderDetail.user_seq
            )
        if not lists :
            raise HTTPException(status_code=400, detail="orderlist not found")
        return {'result' : [
            {
                "id" : list[0],
                "image" : list[1],
                "name" : list[2],
                "count" : list[3]-1,
                "quantity" : list[4],
                "price" : list[5],
                "date" : f"20{list[0][:2]}.{list[0][2:4]}.{list[0][4:6]}"
            }
            for list in lists 
                ]
        }
    except Exception as e:
        return {'result' : e}


@router.get('/home', status_code=200)
async def dashboard(session : Session = Depends(db.session)): 
    """
    관리자 dashboard
    count : 대표 상품 외 상품 갯수
    price : 주문별 금액
    quantity : 
    """
    try :   
        dashs = session.query(
            OrderDetail.id,
            OrderDetail.name, # 유저 이름
            func.min(Product.name).label('name'), # 최근주문 상품 이름
            func.count(Product.name).label('count'), # 최근주문 유저별 대표 상품 외 갯수(ex: 볼펜 외 "2"개)
            func.sum(OrderDetail.price).label('price'), # 최근 주문 유저별 주문 금액(합)
            func.sum(func.sum(OrderDetail.price)).over().label('total_price'), # 총 매출
            func.sum(func.count("*")).over().label('total_order'), # 총 주문 
            func.min(Order.status) # 주문별 배송 상태
        ).join(
            Product,
            Product.id == OrderDetail.product_id
        ).join(
            Order,
            Order.id == OrderDetail.id
        ).group_by(
            OrderDetail.id,
            OrderDetail.name
        ).all()
        if not dashs : 
            raise HTTPException(status_code=400, detail='dashs not found')
        return {'result' :[
            {
                'id' : dash[0],
                'user_name' : dash[1],
                'product_name' : dash[2],
                'count' : dash[3]-1,
                'price' : dash[4],
                'status' : dash[7],
            }
            for dash in dashs[:5]
        ],
        'total_price' : dashs[0][5],
        'total_order' : dashs[0][6]
        }
    except Exception as e :
        print(e)
        return {'result' : e}
 #!/bin/bash

MENU_FILE="menu.txt"
ORDERS_FILE="orders.txt"
SALES_FILE="sales.txt"

# Create files if not exist
touch $MENU_FILE
touch $ORDERS_FILE
touch $SALES_FILE

# ---------------- SHOW MENU ----------------
show_menu() {
    echo "----------- MENU AVAILABLE -----------"
    if [ ! -s $MENU_FILE ]; then
        echo "Menu is empty! Please add items first."
    else
        echo "ID       NAME               PRICE"
        echo "-------------------------------------------"
        awk '{printf "%-8s %-18s %-8s\n", $1, $2, $3}' $MENU_FILE | sed 's/"//g'
    fi
    echo "-------------------------------------------"
}

# ---------------- ADD MENU ITEM ----------------
add_menu_item() {
    echo "Enter Item ID:"
    read id
    echo "Enter Item Name (can contain spaces):"
    read -r name
    echo "Enter Price:"
    read price

    echo "$id \"$name\" $price" >> $MENU_FILE
    echo "✔ Menu item added successfully!"
}

# ---------------- REMOVE MENU ITEM ----------------
remove_menu_item() {
    echo "Enter Item ID to remove:"
    read id

    if grep -q "^$id " "$MENU_FILE"; then
        sed -i "/^$id /d" $MENU_FILE
        echo "✔ Item removed successfully!"
    else
        echo "❌ Item ID not found!"
    fi
}

# ---------------- TAKE MULTIPLE ITEM ORDER ----------------
take_order() {
    echo "Enter Order ID:"
    read oid

    while true
    do
        echo "Enter Item ID:"
        read iid
        echo "Enter Quantity:"
        read qty

        price=$(awk -v id="$iid" '$1==id {print $3}' "$MENU_FILE")

        if [ -z "$price" ]; then
            echo "❌ Item ID not found!"
        else
            total=$(awk -v p="$price" -v q="$qty" 'BEGIN{print p*q}')
            echo "$oid $iid $qty $total" >> $ORDERS_FILE
            echo "$total" >> $SALES_FILE
            echo "✔ Item added!"
        fi

        echo "Add another item? (y/n)"
        read choice
        if [ "$choice" != "y" ]; then
            break
        fi
    done

    echo "✔ Order Completed Successfully!"
}

# ---------------- GENERATE BILL ----------------
generate_bill() {
    echo "Enter Order ID to generate bill:"
    read oid

    order=$(grep "^$oid " "$ORDERS_FILE")

    if [ -z "$order" ]; then
        echo "❌ Order not found!"
    else
        echo "-------------- BILL ----------------"
        echo "Order ID : $oid"
        echo "Name                Price   Qty  Amount"
        echo "------------------------------------------"

        total_sum=0

        while read line
        do
            iid=$(echo $line | awk '{print $2}')
            qty=$(echo $line | awk '{print $3}')
            amount=$(echo $line | awk '{print $4}')

            rawname=$(awk -v id="$iid" '$1==id {print $2}' "$MENU_FILE")
            price=$(awk -v id="$iid" '$1==id {print $3}' "$MENU_FILE")

            name=$(echo "$rawname" | sed 's/"//g')

            printf "%-20s %-7s %-4s %-7s\n" "$name" "$price" "$qty" "$amount"

            total_sum=$(awk -v ts="$total_sum" -v amt="$amount" 'BEGIN{print ts+amt}')
        done < <(grep "^$oid " "$ORDERS_FILE")

        echo "------------------------------------------"
        echo "TOTAL BILL AMOUNT = Rs. $total_sum"
        echo "-------------- THANK YOU ----------------"
    fi
}

# ---------------- CANCEL ORDER ----------------
cancel_order() {
    echo "Enter Order ID to cancel:"
    read oid
    sed -i "/^$oid /d" $ORDERS_FILE
    echo "✔ Order cancelled!"
}

# ---------------- SALES SUMMARY ----------------
sales_summary() {
    total=$(awk '{sum += $1} END {print sum}' $SALES_FILE)
    echo "Total Sales Today = Rs. $total"
}

# ---------------- MAIN MENU ----------------
while true
do
    echo "========================================="
    echo "     RESTAURANT ORDER MANAGEMENT SYSTEM"
    echo "========================================="
    echo "1. Show Menu"
    echo "2. Add Menu Item"
    echo "3. Remove Menu Item"
    echo "4. Take New Order"
    echo "5. Generate Bill"
    echo "6. Cancel Order"
    echo "7. Sales Summary"
    echo "8. Exit"
    echo "========================================="
    echo "Enter choice:"
    read ch

    case $ch in
        1) show_menu ;;
        2) add_menu_item ;;
        3) remove_menu_item ;;
        4) take_order ;;
        5) generate_bill ;;
        6) cancel_order ;;
        7) sales_summary ;;
        8) echo "Goodbye!"; exit ;;
        *) echo "Invalid choice! Try again." ;;
    esac
done

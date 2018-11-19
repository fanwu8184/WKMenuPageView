# Menu Page
![demo1](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo1.gif)
![demo2](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo2.gif)
![demo3](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo3.gif)
![demo4](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo4.gif)
![demo5](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo5.gif)
![demo9](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo9.gif)
![demo7](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo7.gif)
![demo8](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo8.gif)

WkMenuPageView is an easy to use and flexible Menu View for iOS development. What you need to take care are the your menu views and your page views. Menu Page will handle the rest of the logic and functions.
- Swipe Between Pages
- Change Settings Anytime
- Support Device Rotation
- Flexible
- Easy To Use

### Installation
Just need to download the MenuPage and SupportFiles folders into your project.

### How to use
##### Create Your Menu Views
```sh
let imageView: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(named: "calendar")
    return iv
}()
        
let button: UIButton = {
    let b = UIButton()
    b.setImage(UIImage(named: "calendar"), for: .normal)
    b.setTitle("Button", for: .normal)
    return b
}()
```

##### Create Your Page Views
```sh
let pageView: UIView = {
    let view = UIView()
    view.backgroundColor = .red
    return view
}()
        
let pageView2: UIView = {
    let view = UIView()
    view.backgroundColor = .yellow
    return view
}()
        
let pageView3: UIView = {
    let view = UIView()
    view.backgroundColor = .blue
    return view
}()
        
let pageView4: UIView = {
    let view = UIView()
    view.backgroundColor = .green
    return view
}()
```

##### Create MenuPage Instances Via It's Model
You don't have to set menuView parameter. It's default value is a label view
```sh
let aaa = MenuPage(title: "AAA", pageView: pageView)
let bbb = MenuPage(title: "BBB", pageView: pageView2)
let ccc = MenuPage(title: "CCC", menuView: button, pageView: pageView3)
let ddd = MenuPage(title: "DDD", menuView: imageView, pageView: pageView4)
```

##### Create Instance of MenuPageView
```sh
let wkMenuPageView = WKMenuPageView()
wkMenuPageView.menuPages = [aaa, bbb, ccc, ddd]
```
or
```sh
let wkMenuPageView =  WKMenuPageView(menuPages: [aaa, bbb, ccc, ddd])
```

##### Setup MenuPageView
```sh
override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(wkMenuPageView)
        wkMenuPageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        wkMenuPageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        wkMenuPageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        wkMenuPageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
}
```
And done, That is it!

### Features
#### Setting Up Custom View And Manipulate It
![demo2](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo2.gif)
![demo3](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo3.gif)
![demo4](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo4.gif)

Setting up custom view (for example: a view for your logo)
```sh
let a = UIView()
a.backgroundColor = .yellow
wkMenuPageView.menuViewCustomView = a
```
Change the position
```sh
wkMenuPageView.menuCustomContainerPosition = .bottom
```
Change the factor, default is 0.25
```sh
wkMenuPageView.menuCustomContainerFactor = 0.75
```

#### Change Menu Item Hight
![demo5](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo5.gif)

default is 50
```sh
wkMenuPageView.menuItemHeight = 100
```

#### Update Menu Iten
![demo9](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo9.gif)

```sh
var switchStatus = true
@objc func changeMI() {
        if switchStatus {
            wkMenuPageView.menuPages = []
        } else {
            wkMenuPageView.menuPages = [aaa, bbb, ccc, ddd, eee]
        }
        switchStatus = !switchStatus
    }
```

#### Setting Up Indication View
![demo7](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo7.gif)

```sh
wkMenuPageView.menuIndicationView.backgroundColor = .lightGray
```

#### Setting Up Scroll Direction
![demo8](https://github.com/fanwu8184/WKMenuPageView/blob/master/Demos/demo8.gif)

```sh
var switchStatus = true
@objc func changePL() {
        if switchStatus {
            wkMenuPageView.pageScrollDirection = .horizontal
        } else {
            wkMenuPageView.pageScrollDirection = .vertical
        }
        switchStatus = !switchStatus
    }
```

#### Use CustomMenuItem Protocol To Customize Your Selected Or Unselected Menu Item's Behavior
See the example code below
```sh
class CustomMenuView: BasicView, CustomMenuItem {
    
    var isSelected: Bool = false {
        didSet {
            backgroundColor = isSelected ? .black : .orange
        }
    }
    
    override func setupViews() {
        super.setupViews()
    }
}

let customMenuView = CustomMenuView()
let example = MenuPage(title: "example", menuView: customMenuView, pageView: UIView())
```

#### The Other Settings
**Change horizontalMenuOutFactor and verticalOutMenuFactor, default is 0.8**
```sh
wkMenuPageView.horizontalMenuOutFactor = 0.5
wkMenuPageView.verticalOutMenuFactor = 0.5
```
**Change the menu background color, default is UIcolor.white**
```sh
wkMenuPageView.menuViewBackgroundColor = UIColor.lightGray
```

**Change selected menu color, default is UIcolor.red**
```sh
wkMenuPageView.selectedMenuColor = UIColor.yellow
```
**Change not selected menu color, default is UIcolor.blue**
```sh
wkMenuPageView.notSelectedMenuColor = UIColor.yellow
```
**Set up a closure for currentIndexDidChange so that you can track the menu index change**
```sh
wkMenuPageView.currentIndexDidChange = { index in print(menuPage.menuPages[index].title) }

Tip: set this up before you set menuPage.menuPages will let you be able to track the initial value change
```
**Disable pages view bounce**
```sh
wkMenuPageView.setPagesBounce(false)
```

License
----

MIT

**Free Software, Hell Yeah!**

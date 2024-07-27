import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import this for URL launching
import 'login_page.dart'; // Import the login page
import 'dart:io';
import 'package:image_picker/image_picker.dart'; // For using ImagePicker
import 'package:image/image.dart' as img;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // Set the LoginPage as the initial route
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String username;

  MyHomePage({required this.username});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _profileImage;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Check if the file exists before setting the state
        if (await file.exists()) {
          // Read the image file
          final imageBytes = await file.readAsBytes();
          final image = img.decodeImage(imageBytes);

          if (image != null) {
            // Resize the image
            final resizedImage = img.copyResize(image, width: 100, height: 100); // Resize to fit the profile icon

            // Save the resized image
            final resizedImageFile = File('${file.parent.path}/resized_${file.uri.pathSegments.last}');
            resizedImageFile.writeAsBytesSync(img.encodePng(resizedImage));

            setState(() {
              _profileImage = resizedImageFile;
            });
          } else {
            print('Error decoding image.');
          }
        } else {
          print('File does not exist.');
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

 @override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 4,
    child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 22, 39, 58),
        centerTitle: true,  // This centers the title
        iconTheme: IconThemeData(color: Colors.white), // Set the menu icon color to white
        bottom: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.movie_filter_rounded)),
            Tab(icon: Icon(Icons.rate_review)),
            Tab(icon: Icon(Icons.local_movies_rounded)),
            Tab(icon: Icon(Icons.newspaper)),
          ],
        ),
        title: Text(
          'Popcorn Hub',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontFamily: 'Oswald',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 22, 39, 58),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      backgroundColor: Colors.blueAccent,
                      child: _profileImage == null
                          ? Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(widget.username, style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Color.fromARGB(255, 0, 0, 0)),
              title: Text('Home', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: const Color.fromARGB(255, 0, 0, 0)),
              title: Text('Settings', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _showSettingsDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: const Color.fromARGB(255, 0, 0, 0)),
              title: Text('Sign Out', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to the LoginPage
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          HomeScreen(),
          ExploreScreen(username: widget.username),
          MoviePlaylist(),
          NewsScreen(),
        ],
      ),
    ),
  );
}


  void _showSettingsDialog(BuildContext context) {
    String newUsername = widget.username;
    String newEmail = 'john.doe@example.com'; // Initialize with the current email

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Username'),
                onChanged: (value) {
                  newUsername = value;
                },
                controller: TextEditingController(text: newUsername),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  newEmail = value;
                },
                controller: TextEditingController(text: newEmail),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) {
                  // Handle password update logic here if needed
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save the changes
                // Handle password update logic here if needed
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> _movies = [
    {
      'title': 'The Notebook',
      'image': 'assets/images/the notebook.jpg',
      'actors': ['Ryan Gosling', 'Rachel McAdams'],
      'director': 'Nick Cassavetes',
      'url': 'https://fboxz.to/movie/the-notebook-bnaj',
    },
    {
      'title': '500 Days Of Summer',
      'image': 'assets/images/500 days of summer.jpg',
      'actors': ['Zooey Deschanel', 'Joseph Gordon-Levitt'],
      'director': 'Marc Webb',
      'url': 'https://fboxz.to/movie/500-days-of-summer-xevx/1-1',
    },
    {
      'title': 'The Dark Knight',
      'image': 'assets/images/the dark knight.jpg',
      'actors': ['Christian Bale', 'Heath Ledger'],
      'director': 'Christopher Nolan',
      'url': 'https://fboxz.to/movie/the-dark-knight-gblv',
    },
    {
      'title': 'Memento',
      'image': 'assets/images/memento.jpg',
      'actors': ['Guy Pearce', 'Carrie-Anne Moss'],
      'director': 'Christopher Nolan',
      'url': 'https://fboxz.to/movie/memento-dadj',
    },
    {
      'title': 'Tenet',
      'image': 'assets/images/tenet.jpg',
      'actors': ['John David Washington', 'Robert Pattinson'],
      'director': 'Christopher Nolan',
      'url': 'https://fboxz.to/movie/tenet-ogwgk',
    },
    {
      'title': 'About Time',
      'image': 'assets/images/about tme.jpg',
      'actors': ['Domhnall Gleeson', 'Rachel McAdams'],
      'director': 'Richard Curtis',
      'url': 'https://fboxz.to/movie/about-time-jobwe/1-1',
    },
   
    {
      'title': 'Before Sunrise',
      'image': 'assets/images/before sunrs.jpg',
      'actors': ['Ethan Hawke', 'Julie Delpy'],
      'director': 'Richard Linklater',
      'url': 'https://fboxz.to/movie/before-sunrise-bjyp',
    },
    {
      'title': 'Ben-Hur',
      'image': 'assets/images/Benhur.jpg',
      'actors': ['Charlton Heston', 'Jack Hawkins'],
      'director': 'William Wyler',
      'url': 'https://fboxz.to/movie/before-sunrise-bjyp',
    },
  
    {
      'title': 'Crazy Stupid Love',
      'image': 'assets/images/crazy stupid love.jpg',
      'actors': ['Steve Carell', 'Ryan Gosling'],
      'director': 'Glenn Ficarra',
      'url': 'https://fboxz.to/movie/crazy-stupid-love-gjom',
    },
  
    {
      'title': 'Eternal Sunshine Of The Spotless Mind',
      'image': 'assets/images/esotsp.jpg',
      'actors': ['Jim Carrey', 'Kate Winslet'],
      'director': 'Michel Gonedry',
      'url': 'https://fboxz.to/movie/eternal-sunshine-of-the-spotless-mind-ewkd',
    },
    {
      'title': 'Fallen Angels',
      'image': 'assets/images/Fallen angels.jpg',
      'actors': ['Brian Kenneth Pilapil', 'Nathalie Anicas'],
      'director': 'Wong Kar Wai',
      'url': 'https://fboxz.to/movie/fallen-angels-vwpmo',
    },
    {
      'title': 'Flipped',
      'image': 'assets/images/flipped.jpg',
      'actors': ['Madeline Carroll', 'Callan McAuliffe'],
      'director': 'Rob Reiner',
      'url': 'https://fboxz.to/movie/fallen-angels-vwpmo',
    },
    {
      'title': 'Forrest Gump',
      'image': 'assets/images/forrest gump.jpg',
      'actors': ['Tom Hanks', 'Robin Wright'],
      'director': 'Robert Zemeckis',
      'url': 'https://fboxz.to/movie/forrest-gump-qeap',
    },
    {
      'title': 'Friday the 13th',
      'image': 'assets/images/Friday the 13th.jpg',
      'actors': ['Betsy Palmer', 'Adrienne King'],
      'director': 'Sean S. Cunningham',
      'url': 'https://fboxz.to/movie/friday-the-13th-ylvwm',
    },
   
    {
      'title': 'How to Lose a Guy in 10 Days',
      'image': 'assets/images/how to lose a guy in 10 days.jpg',
      'actors': ['Kate Hudson', 'Matthew McConaughey'],
      'director': 'Donald Petrie',
      'url': 'https://fboxz.to/movie/how-to-lose-a-guy-in-10-days-wvmqj/1-1',
    },
   
    {
      'title': 'In the Mood for Love',
      'image': 'assets/images/in the mood for love.jpg',
      'actors': ['Tony Leung', 'Maggie Cheung'],
      'director': 'Wong Kar Wai',
      'url': 'https://fboxz.to/movie/in-the-mood-for-love-pobjm',
    },
  
    {
      'title': 'JAWS',
      'image': 'assets/images/JAWS.jpg',
      'actors': ['Roy Scheider', 'Robert Shaw'],
      'director': 'Steven Spielberg',
      'url': 'https://fboxz.to/movie/jaws-qenmb',
    },
 
    {
      'title': 'La La Land',
      'image': 'assets/images/lalaland.jpg',
      'actors': ['Ryan Gosling', 'Emma Stone'],
      'director': 'Damien Chazelle',
      'url': 'https://fboxz.to/movie/la-la-land-owobn/1-1',
    },
    {
      'title': 'Perks of Being a Wallflower',
      'image': 'assets/images/Perks of being a wallflowe.jpg',
      'actors': ['Logan Lerman', 'Emma Watson'],
      'director': 'Stephen Chbosky',
      'url': 'https://fboxz.to/movie/the-perks-of-being-a-wallflower-xvql',
    },
  
 
    {
      'title': 'Raiders of the Lost Ark',
      'image': 'assets/images/Raiders of the lost ark.jpg',
      'actors': ['Harrison Ford', 'Karen Allen'],
      'director': 'Steven Spielberg',
      'url': 'https://fboxz.to/movie/raiders-of-the-lost-ark-lkdw',
    },
    {
      'title': 'Saving Private Ryan',
      'image': 'assets/images/saving private ryan.jpg',
      'actors': ['Tom Hanks', 'Matt Damon'],
      'director': 'Steven Spielberg',
      'url': 'https://fboxz.to/movie/saving-private-ryan-ponx',
    },
    {
      'title': 'Schindler\'s List',
      'image': 'assets/images/schindler_s list.jpg',
      'actors': ['Liam Neeson', 'Ben Kingsley'],
      'director': 'Steven Spielberg',
      'url': 'https://fboxz.to/movie/schindlers-list-qewl',
    },
    {
      'title': 'Scott Pilgrim vs. the World',
      'image': 'assets/images/SCOTT PILGIRM.jpg',
      'actors': ['Michael Cera', 'Mary Elizabeth Winstead'],
      'director': 'Edgar Wright',
      'url': 'https://fboxz.to/movie/scott-pilgrim-vs-the-world-kbng',
    },
  
    {
      'title': 'Star Wars: The Force Awakens',
      'image': 'assets/images/Star Wars the force awakens.jpg',
      'actors': ['Daisy Ridley', 'John Boyega'],
      'director': 'J.J. Abrams',
      'url': 'https://fboxz.to/movie/star-wars-the-force-awakens-mpdaa',
    },
    {
      'title': 'Submarine',
      'image': 'assets/images/submarine.jpg',
      'actors': ['Craig Roberts', 'Yasmin Paige'],
      'director': 'Richard Ayoade',
      'url': 'https://fboxz.to/movie/submarine-xpabk/1-1',
    },
    {
      'title': 'Texas Chainsaw Beginning',
      'image': 'assets/images/TexasChainsawBeginning.jpg',
      'actors': ['Jordana Brewster', 'Matthew Bomer'],
      'director': 'Jonathan Liebesman',
      'url': 'https://fboxz.to/movie/the-texas-chainsaw-massacre-the-beginning-xqdde/1-1',
    },
    {
      'title': 'The Human Centipede 2',
      'image': 'assets/images/THC2.jpg',
      'actors': ['John Edcel Bico', 'Ken Allen Benedicto'],
      'director': 'Tom Six',
      'url': 'https://fboxz.to/movie/the-human-centipede-ii-full-sequence-2-nyqxe/1-1',
    },
    {
      'title': 'The Girl Next Door',
      'image': 'assets/images/the girl next dooor.jpg',
      'actors': ['Emile Hirsch', 'Elisha Cuthbert'],
      'director': 'Luke Greenfield',
      'url': 'https://fboxz.to/movie/the-girl-next-door-vjlpl',
    },
    {
      'title': 'The Godfather',
      'image': 'assets/images/the godfather.jpg',
      'actors': ['Marlon Brando', 'Al Pacino'],
      'director': 'Francis Ford Coppola',
      'url': 'https://fboxz.to/movie/the-godfather-mpdda',
    },
    {
      'title': 'The Shawshank Redemption',
      'image': 'assets/images/tssr.jpg',
      'actors': ['Tim Robbins', 'Morgan Freeman'],
      'director': 'Frank Darabont',
      'url': 'https://fboxz.to/movie/the-shawshank-redemption-vnwd',
    },
    {
      'title': 'Titanic',
      'image': 'assets/images/titanic.jpg',
      'actors': ['Leonardo DiCaprio', 'Kate Winslet'],
      'director': 'James Cameron',
      'url': 'https://fboxz.to/movie/titanic-wl',
    },
    {
      'title': 'Tayo sa Huling Buwan ng Taon',
      'image': 'assets/images/TSHBNT.jpg',
      'actors': ['Jeah Reloya', 'Angelo Alegre'],
      'director': 'Claarence "Utoy Nimels" Agena',
      'url': 'https://tagalogflix.com/movies/tayo-sa-huling-buwan-ng-taon/',
    },
    {
      'title': 'Twister',
      'image': 'assets/images/Twister.jpg',
      'actors': ['Helen Hunt', 'Bill Paxton'],
      'director': 'Jan de Bont',
      'url': 'https://fboxz.to/movie/twister-wnax',
    },
  ];


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _showMovieDetailsDialog(context, _movies[index]);
          },
          child: Card(
            color: Colors.black,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset(
                  _movies[index]['image']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _movies[index]['title']!,
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 20),
                      SizedBox(width: 5),
                      Text(
                        "4.5/5", // Placeholder rating
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Director: ${_movies[index]['director']}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Actors: ${_movies[index]['actors'].join(', ')}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final url = _movies[index]['url']!;
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // White background
                      foregroundColor: Colors.black, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child: Text('Watch'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMovieDetailsDialog(BuildContext context, Map<String, dynamic> movie) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            movie['title']!,
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Director: ${movie['director']}',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                'Actors:',
                style: TextStyle(color: Colors.white),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: movie['actors'].map<Widget>((actor) {
                  return Text(
                    '- $actor',
                    style: TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                final url = movie['url']!;
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: Text('Watch', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class ExploreScreen extends StatefulWidget {
  final String username;

  ExploreScreen({required this.username});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<Map<String, dynamic>> _movies = [
    {
      'title': 'The Notebook',
      'image': 'assets/images/the notebook.jpg', // Ensure correct image path
      'director': 'Nick Cassavetes',
      'rating': 4.5,
      'reviews': [
        {
          'user': 'Emjay',
          'review': 'Sobrsng sarap insan, talagang kinilig ako at natuwa, EYYYY',
          'rating': 5,
          'likes': 10,
          'comments': [
            {'user': 'Zoe', 'comment': 'OMSIM!!!! SOBRA NA SOLID', 'likes': 2},
          ],
        },
        {
          'user': 'Shabulalord',
          'review': 'SOLIDDDDDDD',
          'rating': 4,
          'likes': 5,
          'comments': [],
        },
      ],
    },

    {
      'title': '500 Days Of Summer',
      'image': 'assets/images/500 days of summer.jpg', // Ensure correct image path
      'director': 'Marc Webb',
      'rating': 4.0,
      'reviews': [
        {
          'user': 'Brian',
          'review': 'HAHAHAHA Lil Makasalanan Shorty',
          'rating': 4,
          'likes': 7,
          'comments': [
            {'user': 'Bob', 'comment': 'Indeed!', 'likes': 1},
          ],
        },
      ],
    },

     {
    'title': 'The Grand Budapest Hotel',
    'image': 'assets/images/tgbh.jpg',
    'director': 'Wes Anderson',
    'rating': 4.6,
    'reviews': [
      {
        'user': 'George',
        'review': 'A visually stunning and quirky film.',
        'rating': 5,
        'likes': 12,
        'comments': [
          {'user': 'Hannah', 'comment': 'Wes Anderson at his best!', 'likes': 4},
        ],
      },
    ],
  },
  {
    'title': 'The Shawshank Redemption',
    'image': 'assets/images/tssr.jpg',
    'director': 'Frank Darabont',
    'rating': 4.9,
    'reviews': [
      {
        'user': 'Michael',
        'review': 'An incredible story of hope and friendship.',
        'rating': 5,
        'likes': 25,
        'comments': [
          {'user': 'Lisa', 'comment': 'A masterpiece!', 'likes': 8},
        ],
      },
    ],
  },
  {
    'title': 'The Matrix',
    'image': 'assets/images/thematrix.jpg',
    'director': 'Lana Wachowski, Lilly Wachowski',
    'rating': 4.8,
    'reviews': [
      {
        'user': 'Sarah',
        'review': 'A groundbreaking sci-fi film with an amazing story.',
        'rating': 5,
        'likes': 18,
        'comments': [
          {'user': 'Tom', 'comment': 'A classic!', 'likes': 7},
        ],
      },
    ],
  },
  {
    'title': 'Inception',
    'image': 'assets/images/inception.jpg',
    'director': 'Christopher Nolan',
    'rating': 4.7,
    'reviews': [
      {
        'user': 'Emily',
        'review': 'A mind-bending journey through dreams.',
        'rating': 5,
        'likes': 20,
        'comments': [
          {'user': 'Michael', 'comment': 'Complex and brilliant!', 'likes': 6},
        ],
      },
    ],
  },
  {
    'title': 'Pulp Fiction',
    'image': 'assets/images/pulpfiction.jpg',
    'director': 'Quentin Tarantino',
    'rating': 4.5,
    'reviews': [
      {
        'user': 'Jessica',
        'review': 'A brilliant and unique storytelling experience.',
        'rating': 4,
        'likes': 15,
        'comments': [
          {'user': 'Mark', 'comment': 'Tarantino’s best work!', 'likes': 5},
        ],
      },
    ],
  },
  {
    'title': 'Spirited Away',
    'image': 'assets/images/spiritedaway.jpg',
    'director': 'Hayao Miyazaki',
    'rating': 4.9,
    'reviews': [
      {
        'user': 'Nina',
        'review': 'A beautifully crafted and enchanting animated film.',
        'rating': 5,
        'likes': 22,
        'comments': [
          {'user': 'Alex', 'comment': 'Absolutely magical!', 'likes': 9},
        ],
      },
    ],
  },
  {
    'title': 'The Godfather',
    'image': 'assets/images/the godfather.jpg',
    'director': 'Francis Ford Coppola',
    'rating': 4.9,
    'reviews': [
      {
        'user': 'John',
        'review': 'A timeless masterpiece of cinema.',
        'rating': 5,
        'likes': 30,
        'comments': [
          {'user': 'Anna', 'comment': 'An epic film!', 'likes': 12},
        ],
      },
    ],
  },
  {
    'title': 'The Silence of the Lambs',
    'image': 'assets/images/tsotl.jpg',
    'director': 'Jonathan Demme',
    'rating': 4.8,
    'reviews': [
      {
        'user': 'Sophie',
        'review': 'A chilling and brilliant thriller.',
        'rating': 5,
        'likes': 16,
        'comments': [
          {'user': 'Rachel', 'comment': 'An unforgettable film!', 'likes': 7},
        ],
      },
    ],
  },
  {
    'title': 'Fight Club',
    'image': 'assets/images/fc.jpg',
    'director': 'David Fincher',
    'rating': 4.7,
    'reviews': [
      {
        'user': 'David',
        'review': 'A provocative and thought-provoking film.',
        'rating': 5,
        'likes': 18,
        'comments': [
          {'user': 'Laura', 'comment': 'A modern classic!', 'likes': 5},
        ],
      },
    ],
  },
  {
    'title': 'The Usual Suspects',
    'image': 'assets/images/tus.jpg',
    'director': 'Bryan Singer',
    'rating': 4.7,
    'reviews': [
      {
        'user': 'Daniel',
        'review': 'A masterfully crafted crime thriller.',
        'rating': 5,
        'likes': 14,
        'comments': [
          {'user': 'Sophia', 'comment': 'An incredible twist ending!', 'likes': 6},
        ],
      },
    ],
  },
  {
    'title': 'Mad Max: Fury Road',
    'image': 'assets/images/madmax.jpg',
    'director': 'George Miller',
    'rating': 4.8,
    'reviews': [
      {
        'user': 'Jake',
        'review': 'A high-octane, visually stunning action film.',
        'rating': 5,
        'likes': 21,
        'comments': [
          {'user': 'Hannah', 'comment': 'Non-stop action and thrills!', 'likes': 8},
        ],
      },
    ],
  },
];
  

  void _addReview(Map<String, dynamic> movie, String reviewText, int rating) {
    setState(() {
      movie['reviews'].add({
        'user': widget.username,
        'review': reviewText,
        'rating': rating,
        'likes': 0,
        'comments': [],
      });
    });
  }

  void _addComment(Map<String, dynamic> review, String commentText) {
    setState(() {
      review['comments'].add({
        'user': widget.username,
        'comment': commentText,
        'likes': 0,
      });
    });
  }

  void _showAddReviewDialog(BuildContext context, Map<String, dynamic> movie) {
    String reviewText = '';
    int rating = 5;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Review'),
                onChanged: (value) {
                  reviewText = value;
                },
              ),
              DropdownButton<int>(
                value: rating,
                items: List.generate(5, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text((index + 1).toString()),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    rating = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (reviewText.isNotEmpty) {
                  _addReview(movie, reviewText, rating);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCommentDialog(BuildContext context, Map<String, dynamic> review) {
    String commentText = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Comment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Comment'),
                onChanged: (value) {
                  commentText = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (commentText.isNotEmpty) {
                  _addComment(review, commentText);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _movies.isNotEmpty
      ? ListView.builder(
          itemCount: _movies.length,
          itemBuilder: (context, index) {
            final movie = _movies[index];
            return Card(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        movie['image'],
                        width: 240,
                        height: 360,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie['title'],
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.yellow),
                              SizedBox(width: 5),
                              Text(
                                movie['rating'].toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Director: ${movie['director']}',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: movie['reviews'].map<Widget>((review) {
                              return Card(
                                color: Color.fromARGB(255, 22, 39, 58),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review['user'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        review['review'],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.thumb_up,
                                                color: Colors.blue, size: 16),
                                            onPressed: () {
                                              setState(() {
                                                review['likes']++;
                                              });
                                            },
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            review['likes'].toString(),
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          SizedBox(width: 15),
                                          IconButton(
                                            icon: Icon(Icons.comment,
                                                color: Colors.grey, size: 16),
                                            onPressed: () {
                                              _showAddCommentDialog(
                                                  context, review);
                                            },
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            review['comments'].length.toString(),
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: review['comments']
                                            .map<Widget>((comment) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.reply,
                                                    color: Colors.grey, size: 16),
                                                SizedBox(width: 5),
                                                Text(
                                                  comment['user'],
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  comment['comment'],
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                SizedBox(width: 5),
                                                IconButton(
                                                  icon: Icon(Icons.thumb_up,
                                                      color: Colors.blue,
                                                      size: 16),
                                                  onPressed: () {
                                                    setState(() {
                                                      comment['likes']++;
                                                    });
                                                  },
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  comment['likes'].toString(),
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 8.0),
                          ElevatedButton(
                            onPressed: () {
                              _showAddReviewDialog(context, movie);
                            },
                            child: Text('Add Review'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
      : Center(
          child: Text(
            'No movies available',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        );
  }
}
class MoviePlaylist extends StatelessWidget {
  // Define the movies for each category
  final List<Map<String, String>> _romanticMovies = [
    {
      'title': 'The Notebook',
      'image': 'assets/images/the notebook.jpg',
      'url': 'https://fboxz.to/movie/the-notebook-bnaj',
    },
    {
      'title': '500 Days Of Summer',
      'image': 'assets/images/500 days of summer.jpg',
      'url': 'https://fboxz.to/movie/500-days-of-summer-xevx/1-1',
    },
    {
      'title': 'About Time',
      'image': 'assets/images/about tme.jpg',
      'url': 'https://fboxz.to/movie/about-time-jobwe',
    },
    {
      'title': 'La La Land',
      'image': 'assets/images/lalaland.jpg',
      'url': 'https://fboxz.to/movie/la-la-land-owobn/1-1',
    },
    {
      'title': 'Crazy Stupid Love',
      'image': 'assets/images/crazy stupid love.jpg',
      'url': 'https://fboxz.to/movie/crazy-stupid-love-gjom/1-1',
    },
  ];

  final List<Map<String, String>> _thrillerMovies = [
    {
      'title': 'Inception',
      'image': 'assets/images/inception.jpg',
      'url': 'https://fboxz.to/movie/inception-odpk',
    },
    {
      'title': 'Shutter Island',
      'image': 'assets/images/shutterisland.jpg',
      'url': 'https://fboxz.to/movie/shutter-island-bjxp',
    },
    {
      'title': 'Se7en',
      'image': 'assets/images/se7en.jpg',
      'url': 'https://fboxz.to/movie/se7en-wygp',
    },
    {
      'title': 'Gone Girl',
      'image': 'assets/images/gonegirl.jpg',
      'url': 'https://fboxz.to/movie/gone-girl-vnvd',
    },
    {
      'title': 'The Silence of the Lambs',
      'image': 'assets/images/tsotl.jpg',
      'url': 'https://ww4.123moviesfree.net/movie/the-silence-of-the-lambs-10213/',
    },
  ];

  final List<Map<String, String>> _actionMovies = [
    {
      'title': 'The Dark Knight',
      'image': 'assets/images/the dark knight.jpg',
      'url': 'https://fboxz.to/movie/the-dark-knight-gblv',
    },
    {
      'title': 'Memento',
      'image': 'assets/images/memento.jpg',
      'url': 'https://fboxz.to/movie/memento-dadj',
    },
    {
      'title': 'Tenet',
      'image': 'assets/images/tenet.jpg',
      'url': 'https://fboxz.to/movie/tenet-ogwgk/1-1',
    },
    {
      'title': 'Mad Max: Fury Road',
      'image': 'assets/images/madmax.jpg',
      'url': 'https://fboxz.to/movie/mad-max-fury-road-joqwk',
    },
    {
      'title': 'Gladiator',
      'image': 'assets/images/glad.jpg',
      'url': 'https://fboxz.to/movie/gladiator-oeogk',
    },
  ];

  final List<Map<String, String>> _comedyMovies = [
    {
      'title': 'Superbad',
      'image': 'assets/images/superbad.jpg',
      'url': 'https://fboxz.to/movie/superbad-eaxa',
    },
    {
      'title': 'The Hangover',
      'image': 'assets/images/hangover.jpg',
      'url': 'https://fboxz.to/movie/the-hangover-bxnk',
    },
    {
      'title': 'Step Brothers',
      'image': 'assets/images/stepbrothers.jpg',
      'url': 'https://fboxz.to/movie/step-brothers-gdxw',
    },
    {
      'title': 'Anchorman',
      'image': 'assets/images/anchorman.jpg',
      'url': 'https://fboxz.to/movie/anchorman-the-legend-of-ron-burgundy-kxje',
    },
    {
      'title': 'Dumb and Dumber',
      'image': 'assets/images/dad.jpg',
      'url': 'https://fboxz.to/movie/dumb-and-dumber-wxqen',
    },
  ];

  final List<Map<String, String>> _dramaMovies = [
    {
      'title': 'Forrest Gump',
      'image': 'assets/images/forrest gump.jpg',
      'url': 'https://fboxz.to/movie/forrest-gump-qeap/1-1',
    },
    {
      'title': 'The Shawshank Redemption',
      'image': 'assets/images/tssr.jpg',
      'url': 'https://fboxz.to/movie/the-shawshank-redemption-vnwd',
    },
    {
      'title': 'Fight Club',
      'image': 'assets/images/fc.jpg',
      'url': 'https://fboxz.to/movie/fight-club-eleo',
    },
    {
      'title': 'The Godfather',
      'image': 'assets/images/the godfather.jpg',
      'url': 'https://fboxz.to/movie/the-godfather-mpdda',
    },
    {
      'title': 'Schindler\'s List',
      'image': 'assets/images/schindler_s list.jpg',
      'url': 'https://fboxz.to/movie/schindlers-list-qewl',
    },
  ];

  // Method to build the container for each movie category
  Widget _buildPlaylistContainer(BuildContext context, String categoryTitle, List<Map<String, String>> movies) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Container(
                  width: 150, // Fixed width for each movie item
                  margin: EdgeInsets.only(right: 8.0), // Margin between items
                  child: GestureDetector(
                    onTap: () async {
                      final url = movie['url']!;
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Card(
                      color: Colors.black,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              movie['image']!,
                              width: 150,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            movie['title']!,
                            style: TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis, // Handle long titles
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPlaylistContainer(context, 'Romantic Movies', _romanticMovies),
          _buildPlaylistContainer(context, 'Thriller Movies', _thrillerMovies),
          _buildPlaylistContainer(context, 'Action Movies', _actionMovies),
          _buildPlaylistContainer(context, 'Comedy Movies', _comedyMovies),
          _buildPlaylistContainer(context, 'Drama Movies', _dramaMovies),
        ],
      ),
    );
  }
}

class NewsScreen extends StatelessWidget {
  final List<Map<String, String>> _news = [
    {
      'title': 'New Movie Release',
      'description': 'A new blockbuster movie is releasing this weekend.',
      'date': '2023-07-17',
      'url': 'https://editorial.rottentomatoes.com/guide/popular-movies/',
    },
    {
      'title': 'Actor Interview',
      'description': 'An exclusive interview with a famous actor.',
      'date': '2023-07-16',
      'url': 'https://www.bing.com/videos/search?q=actor+interviews&qpvt=actor+interviews&FORM=VDRE',
    },
    {
      'title': 'Award Ceremony',
      'description': 'Highlights from the latest award ceremony.',
      'date': '2023-07-15',
      'url': 'https://ew.com/award-shows-2024-calendar-dates-8410259#:~:text=Upcoming%20key%20show%20dates%20for%20the%202024%20awards,December%202024%20Dec.%209%3A%20Golden%20Globe%20nominations%20y',
    },
  ];

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Container(), // Removes the title
      ),
      backgroundColor: Colors.black, // Sets the background color to black
      body: ListView.builder(
        itemCount: _news.length,
        itemBuilder: (context, index) {
          final newsItem = _news[index];
          return GestureDetector(
            onTap: () => _launchURL(newsItem['url']!),
            child: Card(
              color: Colors.black, // Sets the card color to black
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      newsItem['title']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255), // Sets text color to white
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      newsItem['description']!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 255, 255, 255), // Sets text color to white
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      newsItem['date']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 255, 255, 255), // Sets text color to grey
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
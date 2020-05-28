.. title:: Use <img> tag with data:url as embedded image
.. slug::
.. date:: 2018-01-03 20:04:00 UTC
.. description::

``<img>`` tag can treat base64 encoded text for `src` attribute.

.. code:: html

   # normal img tag
   <img src="https://..." width="..." height="..." alt="...">


According **Embedding an image via data: URL** section in `Using images - Web APIs | MDN`_

..

  Another possible way to include images is via the data: url.
  Data URLs allow you to completely define an image as a Base64 encoded string of characters directly in your code.


That's like this:

.. code:: html

   <img src="data:image/png;base64,...">


Pros. is very clear. It reduces a request to fetch that image (DNS lookup, request and downloading etc.). And it might be portable code.

  One advantage of data URLs is that the resulting image is available immediately without another round trip to the server.
  Another potential advantage is that it is also possible to encapsulate in one file all of your CSS, JavaScript, HTML, and images, making it more portable to other locations.


The problem using this way is, that image is not cached, and it's hard for large size image. (usage and for also coding)

..

  Some disadvantages of this method are that your image is not cached, and for larger images the encoded url can become quite long.


Usage
-----


If you have a png file which you want use with this way, how to get encoded text with base64?
That's very easy. For example, in Python.

.. code:: python

   import base64

   text = ''

   with open('/path/to/png', 'rb') as f:
     f.read()  # if you want to check
     f.seek(0)  # and back to 0

     # get encoded binary text
     text = base64.b64encode(f.read())

   print(text.decode())


And just append it to ``data:image/png;base64,`` in ``src`` attribute of ``<img>`` tag.


About its specification and syntax of **data: URL**, You should see `RFC 2397`_  and `Data URLs - HTTP | MDN`_

Syntax is:

.. code:: text

   data:[<mediatype>][;base64],<data>

According to RFC2397, It seems that some applications (browsers?) have length limit for this data URLs.

  The "data:" URL scheme is only useful for short values. Note that
  some applications that use URLs may impose a length limit; for
  example, URLs embedded within <A> anchors in HTML have a length limit
  determined by the SGML declaration for HTML [RFC1866]. The LITLEN
  (1024) limits the number of characters which can appear in a single
  attribute value literal, the ATTSPLEN (2100) limits the sum of all
  lengths of all attribute value specifications which appear in a tag,
  and the TAGLEN (2100) limits the overall length of a tag.

| However, Firefox and most other modern browsers moment don't have length limit for this.
| Anyway, it's apparently bad idea for long (large) size image.


Example
-------

| There is a small ``jpeg`` image of my profile icon :)
| Its size is ``1.3KB``, width is ``25px`` and height is ``25px``.

.. code:: html

   <img src="/attachments/grauwoelfchen.jpg" width=25 height=25 alt="grauwoelfchen">

..
   .. raw:: html

      <img src="/attachments/grauwoelfchen.jpg" width=25 height=25 alt="grauwoelfchen">

.. code:: python

   % python
   >>> import base64
   >>> f = open('/tmp/grauwoelfchen.jpg', 'rb')
   >>> t = base64.b64encode(f.read()
   >>> t.decode()
   '/9j/4AAQSkZJRgABAQEASABIAAD/7QBcUGhvdG9zaG9wIDMuMAA4QklNBAQAAAAAACQcAVoAAxslRxwCAAACAAIcAkYAEFBpeGVsbWF0b3IgMS42LjI4QklNBCUAAAAAABAN4QFFUXvae5OgY6aERRHP/+EAqkV4aWYAAE1NACoAAAAIAAYBEgADAAAAAQABAAABGgAFAAAAAQAAAFYBGwAFAAAAAQAAAF4BKAADAAAAAQACAAABMQACAAAAEQAAAGaHaQAEAAAAAQAAAHgAAAAAAAAASAAAAAEAAABIAAAAAVBpeGVsbWF0b3IgMS42LjIAAAADoAEAAwAAAAH//wAAoAIABAAAAAEAAAAZoAMABAAAAAEAAAAZAAAAAP/bAEMAAgICAgIBAgICAgICAgMDBgQDAwMDBwUFBAYIBwgICAcICAkKDQsJCQwKCAgLDwsMDQ4ODg4JCxARDw4RDQ4ODv/bAEMBAgICAwMDBgQEBg4JCAkODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODv/AABEIABkAGQMBIgACEQEDEQH/xAAfAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgv/xAC1EAACAQMDAgQDBQUEBAAAAX0BAgMABBEFEiExQQYTUWEHInEUMoGRoQgjQrHBFVLR8CQzYnKCCQoWFxgZGiUmJygpKjQ1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4eLj5OXm5+jp6vHy8/T19vf4+fr/xAAfAQADAQEBAQEBAQEBAAAAAAAAAQIDBAUGBwgJCgv/xAC1EQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AP27+IfxB0X4c+AZtc1iQnqsFuhw0rf0A7mvBovi98V9X+HS+JtD8GNczLeMtxorQDzYbbaWSYncWO8dABkjnFU/2gbeG/8A2ofg9p+tTwReGpNSh+0R3LhY5nMpwmDwWOBwOeDXmcXxV8RaN8V/iHZ6VbGwvdb8QHTdPkZgXcoWEflLjuCygdtteDOdXEV5x5+VR0032vc9qlSp0qMZcik5a67b2sfWnwr+K+kfEvQrsQwnT9csm2X9g5+aM5xkZ5xn16V67tHvXxR4B0i50P8A4KJX0Nrc287zaNCut+TIPmuhBukdlHq2Dk/1r7YrryzEzqU2pu7i2r97HJmFCFOonDRNJ27XPIfi18KtG+KXhLS4b6GJtV0i+TUNIuJdwENwn3WyOf5/Q18a+HPgv8dvBPj/AFvUtH0DSdR1jUdQe7OqXmoieGCV0VGkgRj+7HykhTnGT6kD9JB0f60w/fH+9/StK+Vwqz51JxfW3UzoZlOjHkcVJeZ4R8IPg3b+Adf8QeM9YMV1498RJB/bFwkryJmJNoClvx5AFe/VGfvj6VJXTQw1OhTUIo562InWqOUnqf/Z'
   >>> len(t.decode())
   1768
   >>> f.close()

This is a image using data:url

.. code:: html

   <img src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/7QBcUGhvdG9zaG9wIDMuMAA4QklNBAQAAAAAACQcAVoAAxslRxwCAAACAAIcAkYAEFBpeGVsbWF0b3IgMS42LjI4QklNBCUAAAAAABAN4QFFUXvae5OgY6aERRHP/+EAqkV4aWYAAE1NACoAAAAIAAYBEgADAAAAAQABAAABGgAFAAAAAQAAAFYBGwAFAAAAAQAAAF4BKAADAAAAAQACAAABMQACAAAAEQAAAGaHaQAEAAAAAQAAAHgAAAAAAAAASAAAAAEAAABIAAAAAVBpeGVsbWF0b3IgMS42LjIAAAADoAEAAwAAAAH//wAAoAIABAAAAAEAAAAZoAMABAAAAAEAAAAZAAAAAP/bAEMAAgICAgIBAgICAgICAgMDBgQDAwMDBwUFBAYIBwgICAcICAkKDQsJCQwKCAgLDwsMDQ4ODg4JCxARDw4RDQ4ODv/bAEMBAgICAwMDBgQEBg4JCAkODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODv/AABEIABkAGQMBIgACEQEDEQH/xAAfAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgv/xAC1EAACAQMDAgQDBQUEBAAAAX0BAgMABBEFEiExQQYTUWEHInEUMoGRoQgjQrHBFVLR8CQzYnKCCQoWFxgZGiUmJygpKjQ1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4eLj5OXm5+jp6vHy8/T19vf4+fr/xAAfAQADAQEBAQEBAQEBAAAAAAAAAQIDBAUGBwgJCgv/xAC1EQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AP27+IfxB0X4c+AZtc1iQnqsFuhw0rf0A7mvBovi98V9X+HS+JtD8GNczLeMtxorQDzYbbaWSYncWO8dABkjnFU/2gbeG/8A2ofg9p+tTwReGpNSh+0R3LhY5nMpwmDwWOBwOeDXmcXxV8RaN8V/iHZ6VbGwvdb8QHTdPkZgXcoWEflLjuCygdtteDOdXEV5x5+VR0032vc9qlSp0qMZcik5a67b2sfWnwr+K+kfEvQrsQwnT9csm2X9g5+aM5xkZ5xn16V67tHvXxR4B0i50P8A4KJX0Nrc287zaNCut+TIPmuhBukdlHq2Dk/1r7YrryzEzqU2pu7i2r97HJmFCFOonDRNJ27XPIfi18KtG+KXhLS4b6GJtV0i+TUNIuJdwENwn3WyOf5/Q18a+HPgv8dvBPj/AFvUtH0DSdR1jUdQe7OqXmoieGCV0VGkgRj+7HykhTnGT6kD9JB0f60w/fH+9/StK+Vwqz51JxfW3UzoZlOjHkcVJeZ4R8IPg3b+Adf8QeM9YMV1498RJB/bFwkryJmJNoClvx5AFe/VGfvj6VJXTQw1OhTUIo562InWqOUnqf/Z" width=25 height=25 alt="grauwoelfchen">

..
   .. raw:: html

       <img src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/7QBcUGhvdG9zaG9wIDMuMAA4QklNBAQAAAAAACQcAVoAAxslRxwCAAACAAIcAkYAEFBpeGVsbWF0b3IgMS42LjI4QklNBCUAAAAAABAN4QFFUXvae5OgY6aERRHP/+EAqkV4aWYAAE1NACoAAAAIAAYBEgADAAAAAQABAAABGgAFAAAAAQAAAFYBGwAFAAAAAQAAAF4BKAADAAAAAQACAAABMQACAAAAEQAAAGaHaQAEAAAAAQAAAHgAAAAAAAAASAAAAAEAAABIAAAAAVBpeGVsbWF0b3IgMS42LjIAAAADoAEAAwAAAAH//wAAoAIABAAAAAEAAAAZoAMABAAAAAEAAAAZAAAAAP/bAEMAAgICAgIBAgICAgICAgMDBgQDAwMDBwUFBAYIBwgICAcICAkKDQsJCQwKCAgLDwsMDQ4ODg4JCxARDw4RDQ4ODv/bAEMBAgICAwMDBgQEBg4JCAkODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODg4ODv/AABEIABkAGQMBIgACEQEDEQH/xAAfAAABBQEBAQEBAQAAAAAAAAAAAQIDBAUGBwgJCgv/xAC1EAACAQMDAgQDBQUEBAAAAX0BAgMABBEFEiExQQYTUWEHInEUMoGRoQgjQrHBFVLR8CQzYnKCCQoWFxgZGiUmJygpKjQ1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4eLj5OXm5+jp6vHy8/T19vf4+fr/xAAfAQADAQEBAQEBAQEBAAAAAAAAAQIDBAUGBwgJCgv/xAC1EQACAQIEBAMEBwUEBAABAncAAQIDEQQFITEGEkFRB2FxEyIygQgUQpGhscEJIzNS8BVictEKFiQ04SXxFxgZGiYnKCkqNTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqCg4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2dri4+Tl5ufo6ery8/T19vf4+fr/2gAMAwEAAhEDEQA/AP27+IfxB0X4c+AZtc1iQnqsFuhw0rf0A7mvBovi98V9X+HS+JtD8GNczLeMtxorQDzYbbaWSYncWO8dABkjnFU/2gbeG/8A2ofg9p+tTwReGpNSh+0R3LhY5nMpwmDwWOBwOeDXmcXxV8RaN8V/iHZ6VbGwvdb8QHTdPkZgXcoWEflLjuCygdtteDOdXEV5x5+VR0032vc9qlSp0qMZcik5a67b2sfWnwr+K+kfEvQrsQwnT9csm2X9g5+aM5xkZ5xn16V67tHvXxR4B0i50P8A4KJX0Nrc287zaNCut+TIPmuhBukdlHq2Dk/1r7YrryzEzqU2pu7i2r97HJmFCFOonDRNJ27XPIfi18KtG+KXhLS4b6GJtV0i+TUNIuJdwENwn3WyOf5/Q18a+HPgv8dvBPj/AFvUtH0DSdR1jUdQe7OqXmoieGCV0VGkgRj+7HykhTnGT6kD9JB0f60w/fH+9/StK+Vwqz51JxfW3UzoZlOjHkcVJeZ4R8IPg3b+Adf8QeM9YMV1498RJB/bFwkryJmJNoClvx5AFe/VGfvj6VJXTQw1OhTUIo562InWqOUnqf/Z" width=25 height=25 alt="grauwoelfchen">

| I think, the caching issue might be also an advantage for images which we don't want to be cached on browser.
| Recently I used this way for a browser widget's icon to reduce a request to server.

This way might be also good, when you create image programatically.

.. _`Using images - Web APIs | MDN`: https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Using_images#Embedding_an_image_via_data_URL
.. _`RFC 2397`: https://tools.ietf.org/html/rfc2397
.. _`Data URLs - HTTP | MDN`: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs

import 'package:flutter/material.dart';
import 'package:my_tube/models/resource_mt.dart';

class ResourceTile extends StatelessWidget {
  const ResourceTile({super.key, required this.resource});

  final ResourceMT resource;

  @override
  Widget build(BuildContext context) {
    return /* ListTile(
      trailing: setTrailingIcon(),
      leading: resource.thumbnailUrl != null
          ? Image.network(
              resource.thumbnailUrl!,
            )
          : const SizedBox(
              child: Icon(Icons.place),
            ),
      title: Text(
        resource.title ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(resource.channelTitle ?? ''),
    ); */
        Container(
      height: MediaQuery.of(context).size.height * 0.1,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: resource.thumbnailUrl != null
                ? Image.network(
                    resource.thumbnailUrl!,
                    height: MediaQuery.of(context).size.height * 0.09,
                    width: MediaQuery.of(context).size.width * 0.2,
                    fit: BoxFit.cover,
                  )
                : const SizedBox(
                    child: Icon(Icons.place),
                  ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                ),
                Text(resource.channelTitle ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white)),
              ],
            ),
          ),
          setTrailingIcon(context) ?? const SizedBox(),
        ],
      ),
    );
  }

  Widget? setTrailingIcon(BuildContext context) {
    IconData icon;
    switch (resource.kind) {
      case 'youtube#channel':
        icon = Icons.monitor;
      case 'youtube#playlist':
        icon = Icons.playlist_play;

      default:
        icon = Icons.audiotrack_rounded;
    }

    return CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white,
        child: Icon(icon, color: Theme.of(context).colorScheme.primary));
  }
}

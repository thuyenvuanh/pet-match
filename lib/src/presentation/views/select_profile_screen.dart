import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/presentation/widgets/button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/src/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:pet_match/src/presentation/widgets/icon_button.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/utils/constant.dart';
import 'package:pet_match/src/utils/extensions.dart';

class ProfileSelectScreen extends StatefulWidget {
  const ProfileSelectScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSelectScreen> createState() => _ProfileSelectScreenState();
}

class _ProfileSelectScreenState extends State<ProfileSelectScreen> {
  late final ProfileBloc _bloc;
  late StreamSubscription _listener;
  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<ProfileBloc>(context)
      ..add(FetchAvailableProfiles());
    _listener = _bloc.stream.listen((state) {
      if (state is ProfileLoggedIn) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.root.name, (route) => false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _listener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Resource.lightBackground,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          bloc: _bloc,
          buildWhen: (previous, current) {
            var res = current is! LoggingIntoProfile;
            res = res && current is! FetchedError;
            return res;
          },
          builder: (context, state) {
            if (state is FetchedError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Có lỗi xảy ra, vui lòng thử lại sau.'),
                  Button(
                    label: 'Refresh',
                    onTap: () {},
                  ),
                ],
              );
            }
            if (state is FetchedSuccess) {
              return _buildProfiles(state.profiles);
            }
            if (state is NoProfileFetched) {
              return _buildCreateNewProfile();
            }
            return const LoadingIndicator();
          },
        ),
      ),
    );
  }

  Widget _buildProfiles(List<Profile> profiles) {
    return RefreshIndicator(
      onRefresh: () async {
        _bloc.add(FetchAvailableProfiles());
      },
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 70),
              child: Text(
                "Chọn hồ sơ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Resource.primaryColor,
                ),
              ),
            ),
            GridView(
              padding: const EdgeInsets.all(40),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 180 / 255),
              children: [
                ...profiles.map((e) => ProfilePreview(
                      profile: e,
                      onClick: () => _bloc.add(LoginToProfile(e)),
                      bloc: _bloc,
                    )),
                const CreateProfileButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateNewProfile() {
    return RefreshIndicator(
      onRefresh: () async => _bloc.add(FetchAvailableProfiles()),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          width: context.screenSize.width,
          height: context.screenSize.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.only(top: 70),
                child: Text(
                  "Chọn hồ sơ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Resource.primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 50),
              CreateProfileButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePreview extends StatefulWidget {
  const ProfilePreview({
    super.key,
    required this.profile,
    required this.onClick,
    required this.bloc,
  });

  final Profile profile;
  final Function() onClick;
  final ProfileBloc bloc;

  @override
  State<ProfilePreview> createState() => _ProfilePreviewState();
}

class _ProfilePreviewState extends State<ProfilePreview> {
  bool _isLoading = false;
  late final StreamSubscription _listener;

  @override
  void initState() {
    super.initState();
    _listener = widget.bloc.stream.listen((state) {
      setState(() {
        _isLoading = state is LoggingIntoProfile &&
            state.profile.id == widget.profile.id;
      });
    });
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: Resource.defaultBorderRadius,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: widget.profile.avatar!,
              fit: BoxFit.cover,
              placeholder: (context, url) {
                return const LoadingIndicator();
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              clipBehavior: Clip.antiAlias,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: 50,
                  color: Colors.black.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.profile.name!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onClick,
                splashColor: Resource.primaryTintColor,
                overlayColor: MaterialStateColor.resolveWith(
                  (states) => Resource.primaryTintColor,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned.fill(
            child: Offstage(
              offstage: !_isLoading,
              child: const LoadingIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateProfileButton extends StatelessWidget {
  const CreateProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Resource.primaryTintColor,
        overlayColor: MaterialStateColor.resolveWith(
            (states) => Resource.primaryTintColor),
        child: SizedBox(
          height: 230,
          child: AspectRatio(
            aspectRatio: 180 / 255,
            child: RoundedIconButton(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.createProfile.name,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add_circle_outlined,
                    color: Resource.primaryColor,
                    size: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Tạo",
                    style: TextStyle(
                      fontSize: 20,
                      color: Resource.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
